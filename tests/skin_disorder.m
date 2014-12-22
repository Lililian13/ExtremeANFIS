% Classification test

raw = importdata('..datasets\skin.txt');

% -------------------- skin disorder
data_1 = [];
data_2 = [];
class_1 = 1;
class_2 = 2;

% sorting data according to classes
for i = 1:size(raw,1)
    if raw(i,end) == class_1
        data_1 = [data_1; raw(i,:)];
        data_1(end,end) = 1;
    end
end
size_class_1 = size(data_1,1);

for i = 1:size(raw,1)
    if raw(i,end) == class_2
        data_2 = [data_2; raw(i,:)];
        data_1(end,end) = 0;
    end
end
size_class_2 = size(data_2,1);

% setting train-to-test ratio
train_ratio = 0.8;
train_count_1 = floor(size_class_1 * train_ratio);
train_count_2 = floor(size_class_2 * train_ratio);
test_count_1 = size_class_1 - train_count_1;
test_count_2 = size_class_2 - train_count_2;

% setting training and test indices
data_train = [data_1(1:train_count_1,:); data_2(1:train_count_2,:)];
data_test = [data_1(train_count_1 +1 : end, :); data_2(train_count_2 +1 : end, :)];

% train = [d1(1:200, :); d1(226:291, :)];
% test = [d1(201:225, :); d1(292:306, :)];

% Class training
% train_1 = [data_train(:, 1:3), [ones(train_count_1, 1); zeros(train_count_2, 1)]];
% train_2 = [train(:, 1:3), [zeros(200, 1); ones(66, 1)]];

n_mfs = 3;

ex_fis = extreme.exanfis(data_train, n_mfs, 50, data_test);

infis_1 = genfis1(data_train, n_mfs, 'gbellmf');
%infis_2 = genfis1(train_2, n_mfs, 'gbellmf');

afis_1 = anfis(data_train, infis_1, 20);
%afis_2 = anfis(train_2, infis_2, 20);

efis_1 = sir.elanfis(data_train(:, 1:3), data_train(:, 4), n_mfs, 50, data_test(:,1:3), data_test(:,4));
%efis_2 = sir.elanfis(train_2(:, 1:3), train_2(:, 4), n_mfs, 50);

a_1_out = evalfis(data_test(:, 1:3), afis_1);
e_1_out = evalfis(data_test(:, 1:3), efis_1);
ex_1_out = evalfis(data_test(:,1:3), ex_fis);

for i = 1:size(data_test,1)
   if a_1_out(i) < 0.5
       a_1_out(i) = 0;
    else
        a_1_out(i) = 1;
    end
    
   if e_1_out(i) < 0.5
        e_1_out(i) = 0;
    else
        e_1_out(i) = 1;
   end
    if ex_1_out(i) < 0.5
        ex_1_out(i) = 0;
    else
        ex_1_out(i) = 1;
    end
end

out_1 = [ones(test_count_1, 1); zeros(test_count_2, 1)];

a_error_count = sum(a_1_out ~= out_1);
e_error_count = sum(e_1_out ~= out_1);
ex_error_count = sum(ex_1_out ~= out_1);

a_error = 100 * (a_error_count / size(data_test,1))
e_error = 100 * (e_error_count / size(data_test,1))
ex_error = 100 * (ex_error_count / size(data_test,1))