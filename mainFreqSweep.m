%% 扫频干扰检测
clear;
clc;

%% 参数初始化
% 信号参数
power = 1; % 干扰信号功率
sampleNum = 8192; % 采样点
sampleFreq = 5e6; % 采样频率

% 实验参数
jnr = -15:3:0; % 干噪比
jnrLen = length(jnr);
cycleNum = 100; % 检测次数

% 算法参数
falseAlarmProb = 1e-5; % 虚警概率
detectNumThres = 10; % 干扰检出点阈值

% 结果参数
detectRate = zeros(1, jnrLen); % 检测概率

%% 干扰和噪声信号产生
interfNumInfo = zeros(cycleNum, jnrLen); % 干扰检出点

for jnrIdx = 1 : jnrLen
    for cycleIdx = 1 : cycleNum
        % 打印循环信息
        disp(['JNR: ', num2str(jnr(jnrIdx)),...
            '; cycle: ', num2str(cycleIdx), ';']);
        % 扫频干扰信号产生
        rng('default');
        startFreq = rand(1,1)*0.8*sampleFreq + 0.1*sampleFreq; % 干扰信号频率
        freqSweepTime = 0.0016384; %扫频时间
        bandwidth = 0.02 * sampleFreq; % 扫频带宽
        stopFreq = startFreq + bandwidth; % 扫频结束频率
        startOmega = (stopFreq-startFreq) / freqSweepTime; % 初始角频率2*pi*f;
        stepFreqSweep = 1 / sampleFreq;
        startFreqSweep = -freqSweepTime / 2;
        stopFreqSweep = freqSweepTime/2 - 1/sampleFreq;
        %干扰信号相位，服从[0, 2*pi]均匀分布
        phaseFreqSweep = (2*pi).*rand(1, 1);
        nFreqSweep = 1;
        %计算时域表达式
        tFreqSweep = startFreqSweep: stepFreqSweep: stopFreqSweep;
        signalFreqSweep = power * exp(1i*(2*pi*startOmega*(tFreqSweep.^2)/2 + 2*pi*((startFreq+stopFreq)/2)*tFreqSweep + phaseFreqSweep));
        powerFreqSweep = sqrt(power/mean(abs(signalFreqSweep).^2)).*signalFreqSweep;
        noiseFreqSweep = awgn(powerFreqSweep, jnr(jnrIdx), 'measured', 0);
        fftFreqSweep = fft(noiseFreqSweep);
        
        % FCME检测算法
        interfNumInfo(cycleIdx, jnrIdx) = SUB_FcmeAlg(fftFreqSweep,...
            falseAlarmProb);
    end
    findInterf = find(interfNumInfo(:, jnrIdx) >= detectNumThres);
    detectRate(jnrIdx) = length(findInterf) / cycleNum;
end

%% plot
figure (1);
plot(jnr, detectRate, 'k-*');
xlabel('JNR'); ylabel('频域检测率'); legend('扫频');
axis auto; grid on;