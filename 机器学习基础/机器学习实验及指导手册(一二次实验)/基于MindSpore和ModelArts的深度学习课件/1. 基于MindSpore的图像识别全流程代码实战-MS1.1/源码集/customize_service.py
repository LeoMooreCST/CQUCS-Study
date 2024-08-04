from __future__ import absolute_import
from __future__ import division
from __future__ import print_function

import os
import numpy as np
from PIL import Image
from hiai.nn_tensor_lib import NNTensor
from hiai.nntensor_list import NNTensorList
from model_service.hiai_model_service import HiaiBaseService

"""AIPP example
aipp_op {
    aipp_mode: static
    input_format : RGB888_U8

    mean_chn_0 : 123
    mean_chn_1 : 117
    mean_chn_2 : 104
}
"""

labels_list = []

label_txt_path = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'labels.txt')
if os.path.exists(label_txt_path):
  with open(label_txt_path, 'r') as f:
    for line in f:
      if line.strip():
        labels_list.append(line.strip())


def keep_ratio_resize(im, base=256):
  short_side = min(float(im.size[0]), float(im.size[1]))
  resize_ratio = base / short_side
  resize_sides = int(round(resize_ratio * im.size[0])), int(round(resize_ratio * im.size[1]))
  im = im.resize(resize_sides)
  return im


def central_crop(im, base=224):
  width, height = im.size
  left = (width - base) / 2
  top = (height - base) / 2
  right = (width + base) / 2
  bottom = (height + base) / 2
  # Crop the center of the image
  im = im.crop((left, top, right, bottom))
  return im


class DemoService(HiaiBaseService):

  def _preprocess(self, data):

    preprocessed_data = {}
    images = []
    for k, v in data.items():
      for file_name, file_content in v.items():
        image = Image.open(file_content)
        image = keep_ratio_resize(image, base=256)
        image = central_crop(image, base=224)
        image = np.array(image)  # HWC
        # AIPP should use RGB format.
        # mean reg is applied in AIPP.
        # Transpose is applied in AIPP
        tensor = NNTensor(image)
        images.append(tensor)
    tensor_list = NNTensorList(images)
    preprocessed_data['images'] = tensor_list
    return preprocessed_data

  def _inference(self, data, image_info=None):
    result = {}
    for k, v in data.items():
      result[k] = self.model.proc(v)

    return result

  def _postprocess(self, data):
    outputs = {}
    prob = data['images'][0][0][0][0].tolist()
    outputs['scores'] = prob
    labels_list = {0:'daisy',1:'dandelion',2:'roses',3:'sunflowers',4:'tulips'}
    if labels_list:
      outputs['predicted_label'] = labels_list[int(np.argmax(prob))]
    else:
      outputs['predicted_label'] = str(int(np.argmax(prob)))

    return outputs
