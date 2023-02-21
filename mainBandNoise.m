%% ���ִ��������ż��
clear;
clc;

%% ������ʼ��
% �źŲ���
power = 1; % �����źŹ���
sampleNum = 8192; % ������
sampleFreq = 5e6; % ����Ƶ��

% ʵ�����
jnr = -15:5:0; % �����
jnrLen = length(jnr);
cycleNum = 100; % ������

% �㷨����
falseAlarmProb = 1e-5; % �龯����
detectNumThres = 10; % ���ż������ֵ

% �������
detectRate = zeros(1, jnrLen); % ������

%% ���ź������źŲ���
interfNumInfo = zeros(cycleNum, jnrLen); % ���ż����

for jnrIdx = 1 : jnrLen
    for cycleIdx = 1 : cycleNum
        % ��ӡѭ����Ϣ
        disp(['JNR: ', num2str(jnr(jnrIdx)),...
            '; cycle: ', num2str(cycleIdx), ';']);
        % ���ִ������źŲ���
        rng('default');
        allBandNoise = normrnd(0, 1, 1, sampleNum) +...
            1i*normrnd(0, 1, 1, sampleNum);
        rng('default');
        freCenter = rand(1,1)*0.8*sampleFreq + 0.1*sampleFreq; % �����ź�Ƶ��
        bandInterf = 0.005 * sampleFreq; % ���ִ�����
        startBandNoise = -(sampleNum-1) / (2*sampleFreq); % ��ʼλ��
        stepBandNoise = 1 / sampleFreq; % ����
        stopBandNoise = (sampleNum-1) / (2*sampleFreq); % ��ֹλ��
        tBandNoise = startBandNoise : stepBandNoise : stopBandNoise;
        % ������ͨ�˲���
        bandLowPass = sin(2*pi*(bandInterf/2)*tBandNoise) ./ (pi*tBandNoise);
        bandLowPass = bandLowPass / sampleFreq;
        bandFreqShift = exp(1i*(2*pi*freCenter*tBandNoise));
        % BNbandpass=bandLowPass.*bandFreqShift;
        powerBandNoise = filter(bandLowPass,1,[allBandNoise,zeros(1,length(allBandNoise))]);
        powerBandNoise = powerBandNoise((length(allBandNoise)/2)+1:3*length(allBandNoise)/2);
        powerBandNoise = powerBandNoise.*bandFreqShift;
        powerBandNoise = sqrt(power/mean(abs(powerBandNoise).^2)).*powerBandNoise;
        noiseBandNoise = awgn(powerBandNoise, jnr(jnrIdx),'measured',0); 
        noiseBandNoiseFft = fft(noiseBandNoise);

        % FCME����㷨
        interfNumInfo(cycleIdx, jnrIdx) = SUB_FcmeAlg(noiseBandNoiseFft,...
            falseAlarmProb);
    end
    findInterf = find(interfNumInfo(:, jnrIdx) >= detectNumThres);
    detectRate(jnrIdx) = length(findInterf) / cycleNum;
end

%% plot
figure (1);
plot(jnr, detectRate, 'y-*');
xlabel('jnr'); ylabel('Ƶ������'); legend('���ִ�');
axis auto; grid on;