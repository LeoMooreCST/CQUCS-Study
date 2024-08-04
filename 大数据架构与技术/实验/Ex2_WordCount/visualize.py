import os
from wordcloud import WordCloud
from pyecharts.render import make_snapshot
from pyecharts import options as opts
from pyecharts.charts import Pie

SAVAPATH = './results/'

class visualize:

    def rdd2dic(self,resRdd,topK):
        """  
        将RDD转换为字典，并截取指定长度topK  
        :param resRdd: 词频统计降序排序结果RDD，格式为(word, count)  
        :param topK: 截取的指定长度  
        :return: 截取后的字典，格式为{word: count}  
        """  
          
        # 首先，使用takeOrdered方法获取前topK个元素  
        # 假设resRdd已经按降序排序，因此我们使用False作为ascending参数  
        top_k_elements = resRdd.takeOrdered(topK, key=lambda x: x[1], ascending=False)  

        # 然后，将有序列表转换为字典  
        wordDicK = dict(top_k_elements)  
        return wordDicK 

    def drawWorcCloud(self, wordDic):
        """
        根据词频字典，进行词云可视化
        :param wordDic: 词频统计字典
        :return:
        """
        # 生成词云
        wc = WordCloud(
                       background_color='white',
                       max_words=2000,
                       width=1920, height=1080,
                       margin=5)
        wc.generate_from_frequencies(wordDic)
        # 保存结果
        if not os.path.exists(SAVAPATH):
            os.makedirs(SAVAPATH)
        wc.to_file(os.path.join(SAVAPATH, '词云可视化.png'))

    def drawPie(self, wordDic):
        """
        饼图可视化
        :param wordDic: 词频统计字典
        :return:
        """
        key_list = wordDic.keys()      # wordDic所有key组成list
        value_list= wordDic.values()   # wordDic所有value组成list
        def pie_position() -> Pie:
            c = (
                Pie()
                    .add
                    (
                    "",
                    [list(z) for z in zip(key_list, value_list)], # dic -> list
                    center=["35%", "50%"],
                    )
                    .set_global_opts
                    (
                    title_opts=opts.TitleOpts(title='饼图可视化'), # 设置标题
                    legend_opts=opts.LegendOpts(pos_left="15%"),
                    )
                    .set_series_opts(label_opts=opts.LabelOpts(formatter="{b}: {c}"))
            )
            return c
        pie_position().render('123.html')
