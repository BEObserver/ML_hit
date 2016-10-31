%% I. 清空环境变量
clear all
clc

%% II. 训练集/测试集产生
%%
% 1. 导入数据
load spectra_data.mat

%%
% 2. 随机产生训练集和测试集
temp = randperm(size(NIR,1));
% 训练集――50个样本
P_train = NIR(temp(1:50),:)';
T_train = octane(temp(1:50),:)';
% 测试集――10个样本
P_test = NIR(temp(51:end),:)';
T_test = octane(temp(51:end),:)';

%% III. 数据归一化
[p_train, ps_input] = mapminmax(P_train,0,1);
p_test = mapminmax('apply',P_test,ps_input);

[t_train, ps_output] = mapminmax(T_train,0,1);

%% IV. BP神经网络创建、训练及仿真测试
% 1. 创建网络
net = feedforwardnet(25);
net.layers{2}.transferFcn = 'logsig';
net.divideParam.trainRatio=0.9;
net.divideParam.valRatio=0.05;
net.divideParam.testRatio=0.05;

%%
% 2. 设置训练参数
net.trainparam.max_fail = 10;
net.trainparam.show = 50;
net.trainparam.epochs = 1000;
net.trainparam.goal = 0.01;
net.trainparam.lr = 0.01;
%%
% 3. 训练网络
net = train(net, p_train, t_train);
%%
% 4. 仿真测试
t_sim = sim(net, p_test);
%%
% 5. 数据反归一化
T_sim = mapminmax.reverse(t_sim, ps_output);

%% V. 性能评价
%%
% 1. 相对误差error
% T_sim = 你的网络在测试数据集上的仿真值
error = abs(T_sim - T_test)./T_test;
N = 10;
%%
% 2. 决定系数R^2
R2 = (N * sum(T_sim .* T_test) - sum(T_sim) * sum(T_test))^2 / ((N * sum((T_sim).^2) - (sum(T_sim))^2) * (N * sum((T_test).^2) - (sum(T_test))^2)); 

%%
% 3. 结果对比
result = [T_test' T_sim' error']

%% VI. 绘图
figure
plot(1:N,T_test,'b:*',1:N,T_sim,'r-o')
legend('True','Predict')
xlabel('Predict Sample')
ylabel('octane')
string = {['R^2=' num2str(R2)]};
title(string)