# 干扰检测仿真
基于能量的频域干扰检测，使用FCME（前向连续均值剔除）算法，对单音干扰/多音干扰/部分带噪声干扰/扫频干扰进行了检测仿真

仿真步骤：
1. 产生干扰信号，并加入高斯白噪声
2. 设计算法，检测是否存在干扰
3. 画出干扰检测概率对干噪比的仿真曲线

仿真结果：
10000次模拟，所有干扰在干噪比-10dB及以上，都能实现100%的检测率，仿真结果见detectRatePlot.jpg

算法原理：
对频谱能量进行排序，以白噪声为基础设置能量递增的阈值，超过阈值一定点数即检测到干扰信号

参数自定义：
采样点数8192 / 采样频率5e6 Hz / 干噪比-15到0 dB / 仿真次数10000 / 算法虚警概率1e-5 / 算法检出点阈值1~10

# Interference detection simulation

Frequency domain interference detection based on energy, using FCME (forward continuous mean elimination) algorithm, the detection simulation of single interference/multi interference/partial band noise interference/swept frequency interference is carried out

Simulation steps:

1. Generate interference signal and add white Gaussian noise

2. Design algorithm to detect whether there is interference

3. Draw the simulation curve of interference detection probability to interference noise ratio

Simulation results:

After 10000 simulations, 100% detection rate can be achieved for all interferences with a dry noise ratio of - 10dB and above. See detectRatePlot.jpg for simulation results

Algorithm description:

Sort the spectrum energy and set the threshold of energy increase based on white noise. If the threshold is exceeded by a certain number of points, the interference signal will be detected

Parameter setting:

Sampling points 8192 / sampling frequency 5e6 Hz / interference to noise ratio - 15 to 0 dB / simulation times 10000 / algorithm false alarm probability 1e-5 / algorithm detection point threshold 1~10
