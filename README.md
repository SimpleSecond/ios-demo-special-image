# ios-demo-special-image
图片处理的几种算法（灰度算法、颜色反转、映射美白算法），可用于相机特效的处理

1、方法：将UIImage转换成unsigned char *
2、方法：将unsigned char * 转换成UIImage
3、灰度算法
      gray = 0.299 * red + 0.587 * green + 0.114 * blue
      gray = red * 77 / 255 + green * 151 / 255 + blue * 88 / 255
4、颜色反转
      newValue = 255 - oldValue
5、美白算法
      a. 最小二乘法曲线拟合
      b. 公式推导
      c. 工具分析：Matlab
      d. 深度学习
      e. 映射表（demo中实现该算法）
