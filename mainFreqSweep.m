%% ɨƵ���ż��
clear;
clc;

%% ������ʼ��
% �źŲ���
power = 1; % �����źŹ���
sampleNum = 8192; % ������
sampleFreq = 5e6; % ����Ƶ��

% ʵ�����
jnr = -15:3:0; % �����
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
        % ɨƵ�����źŲ���
        rng('default');
        startFreq = rand(1,1)*0.8*sampleFreq + 0.1*sampleFreq; % �����ź�Ƶ��
        freqSweepTime = 0.0016384; %ɨƵʱ��
        bandwidth = 0.02 * sampleFreq; % ɨƵ����
        stopFreq = startFreq + bandwidth; % ɨƵ����Ƶ��
        startOmega = (stopFreq-startFreq) / freqSweepTime; % ��ʼ��Ƶ��2*pi*f;
        stepFreqSweep = 1 / sampleFreq;
        startFreqSweep = -freqSweepTime / 2;
        stopFreqSweep = freqSweepTime/2 - 1/sampleFreq;
        %�����ź���λ������[0, 2*pi]���ȷֲ�
        phaseFreqSweep = (2*pi).*rand(1, 1);
        nFreqSweep = 1;
        %����ʱ����ʽ
        tFreqSweep = startFreqSweep: stepFreqSweep: stopFreqSweep;
        signalFreqSweep = power * exp(1i*(2*pi*startOmega*(tFreqSweep.^2)/2 + 2*pi*((startFreq+stopFreq)/2)*tFreqSweep + phaseFreqSweep));
        powerFreqSweep = sqrt(power/mean(abs(signalFreqSweep).^2)).*signalFreqSweep;
        noiseFreqSweep = awgn(powerFreqSweep, jnr(jnrIdx), 'measured', 0);
        fftFreqSweep = fft(noiseFreqSweep);
        
        % FCME����㷨
        interfNumInfo(cycleIdx, jnrIdx) = SUB_FcmeAlg(fftFreqSweep,...
            falseAlarmProb);
    end
    findInterf = find(interfNumInfo(:, jnrIdx) >= detectNumThres);
    detectRate(jnrIdx) = length(findInterf) / cycleNum;
end

%% plot
figure (1);
plot(jnr, detectRate, 'k-*');
xlabel('JNR'); ylabel('Ƶ������'); legend('ɨƵ');
axis auto; grid on;