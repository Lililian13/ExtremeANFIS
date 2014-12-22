% Classification test for vertebral column dataset
% 3 classes, training 3 classifiers 
%
% Dataset has been modified to add column names (A, B, C . . . G)
% 6 features, 3 classes and 310 instances
% Classes are 'DH', 'SL' and 'NO' with frequency of 60, 150 and 100

clear all; close all; clc;
addpath '../../packages/';

data = readtable('vertebral.dat', 'Delimiter' ,' ');

% Classes represented in numerical format
DH_idx = strcmp(data.G, 'DH') * 1;
SL_idx = strcmp(data.G, 'SL') * 2;
NO_idx = strcmp(data.G, 'NO') * 3;
idx = sum([DH_idx, SL_idx, NO_idx], 2);

% Filtering numbers
data = [table2array(data(:, 1:6)), idx];

% Test train split with ratio 0.2 (takes care of extremes)
[test, train, n_test, ~] = util.test_train_split(data, 0.2);

% Creating data for each classifier
train_1 = [train(:, 1:end-1), train(:, end) == 1];
train_2 = [train(:, 1:end-1), train(:, end) == 2];
train_3 = [train(:, 1:end-1), train(:, end) == 3];

% Removing output from test
test = test(:, 1:end-1);

test_out = [[ones(n_test(1), 1); zeros(n_test(2) + n_test(3), 1)], ...
            [zeros(n_test(1), 1); ones(n_test(2), 1); zeros(n_test(3), 1)], ...
            [zeros(n_test(1) + n_test(2), 1); ones(n_test(3), 1)]];
        
% Constants
n_mfs = 2;
anfis_iter = 10;
elanfis_iter = 50;

% Training anfis
anfis_1 = anfis(train_1, n_mfs, anfis_iter);
anfis_2 = anfis(train_2, n_mfs, anfis_iter);
anfis_3 = anfis(train_3, n_mfs, anfis_iter);

% Training elanfis
elanfis_1 = sir.elanfis(train_1(:, 1:end-1), train_1(:, end), n_mfs, elanfis_iter, test, test_out(:, 1));
elanfis_2 = sir.elanfis(train_2(:, 1:end-1), train_2(:, end), n_mfs, elanfis_iter, test, test_out(:, 2));
elanfis_3 = sir.elanfis(train_3(:, 1:end-1), train_3(:, end), n_mfs, elanfis_iter, test, test_out(:, 3));

% Training exanfis (diagnostic purpose)
exanfis_1 = extreme.exanfis(train_1, n_mfs, elanfis_iter, [test, test_out(:, 1)]);
exanfis_2 = extreme.exanfis(train_2, n_mfs, elanfis_iter, [test, test_out(:, 2)]);
exanfis_3 = extreme.exanfis(train_3, n_mfs, elanfis_iter, [test, test_out(:, 3)]);

% Training zanfis
zfis_1 = zfis.zfis(train_1, n_mfs, elanfis_iter, [test, test_out(:, 1)]);
zfis_2 = zfis.zfis(train_2, n_mfs, elanfis_iter, [test, test_out(:, 2)]);
zfis_3 = zfis.zfis(train_3, n_mfs, elanfis_iter, [test, test_out(:, 3)]);

% Testing

anfis_out = zeros(size(test, 1), 3);
elanfis_out = zeros(size(test, 1), 3);
exanfis_out = zeros(size(test, 1), 3);
zfis_out = zeros(size(test, 1), 3);

anfis_out(:, 1) = evalfis(test, anfis_1);
anfis_out(:, 2) = evalfis(test, anfis_2);
anfis_out(:, 3) = evalfis(test, anfis_3);

elanfis_out(:, 1) = evalfis(test, elanfis_1);
elanfis_out(:, 2) = evalfis(test, elanfis_2);
elanfis_out(:, 3) = evalfis(test, elanfis_3);

exanfis_out(:, 1) = evalfis(test, exanfis_1);
exanfis_out(:, 2) = evalfis(test, exanfis_2);
exanfis_out(:, 3) = evalfis(test, exanfis_3);

zfis_out(:, 1) = evalfis(test, zfis_1);
zfis_out(:, 2) = evalfis(test, zfis_2);
zfis_out(:, 3) = evalfis(test, zfis_3);

% Resolving classes
e_out = util.softmax(elanfis_out);
a_out = util.softmax(anfis_out);
ex_out = util.softmax(exanfis_out);
z_out = util.softmax(zfis_out);

% Printing percentage error in each method
anfis_err = sum(sum(abs(test_out - a_out))) * 50 / size(test, 1)
elanfis_err = sum(sum(abs(test_out - e_out))) * 50 / size(test, 1)
exanfis_err = sum(sum(abs(test_out - ex_out))) * 50 / size(test, 1)
zfis_err = sum(sum(abs(test_out - z_out))) * 50 / size(test, 1)