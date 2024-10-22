package util;

import java.util.List;

public class Formatter {
    /**
     * 打印表格
     * @param headers 表头
     * @param rows 表格数据
     *
     * 经过尝试发现无法将中英文完全对齐，因为中文字符并不是严格占两个字符的宽度
     */
    // 打印表格
    public static void printTable(String[] headers, List<String[]> rows) {
        // 计算每列的最大宽度，设置一个最小宽度避免列宽过窄
        int[] columnWidths = new int[headers.length];
        int minColumnWidth = 10; // 每列至少10字符宽

        // 获取每个表头的宽度，并确保宽度不小于最小宽度
        for (int i = 0; i < headers.length; i++) {
            columnWidths[i] = Math.max(getDisplayWidth(headers[i]), minColumnWidth);
        }

        // 计算每一行的宽度，动态调整列宽
        for (String[] row : rows) {
            for (int i = 0; i < row.length; i++) {
                columnWidths[i] = Math.max(columnWidths[i], getDisplayWidth(row[i]));
            }
        }

        // 打印表头
        printRow(headers, columnWidths);
        printSeparator(columnWidths);

        // 打印每一行
        for (String[] row : rows) {
            printRow(row, columnWidths);
        }
    }

    // 打印一行
    private static void printRow(String[] row, int[] columnWidths) {
        StringBuilder sb = new StringBuilder();
        sb.append("|");

        for (int i = 0; i < row.length; i++) {
            String cell = row[i];
            int displayWidth = getDisplayWidth(cell);
            sb.append(" ").append(cell);

            // 填充空格，确保对齐
            sb.append(" ".repeat(columnWidths[i] - displayWidth)).append(" |");
        }

        System.out.println(sb.toString());
    }

    // 打印分隔线
    private static void printSeparator(int[] columnWidths) {
        StringBuilder sb = new StringBuilder();
        sb.append("+");

        for (int width : columnWidths) {
            sb.append("-".repeat(width + 2)).append("+");
        }

        System.out.println(sb.toString());
    }

    // 计算字符串的显示宽度，考虑到中英文字符的不同宽度
    private static int getDisplayWidth(String s) {
        int width = 0;
        for (char c : s.toCharArray()) {
            // 假设中文字符占2个单位宽度，其他字符占1个单位宽度
            if (isChinese(c)) {
                width += 2;
            } else {
                width += 1;
            }
        }
        return width;
    }

    // 判断字符是否是中文字符
    private static boolean isChinese(char c) {
        return String.valueOf(c).matches("[\u4e00-\u9fff]");
    }
}
