function [config,net_cpu] = train_coop_config

    %string for data path
    config.file_str = 'escher/';
    config.process_ims = 0; % 1 to create image patches from original im
    config.process_str = 'escher/original/dogs.jpg'; %name of original image
    config.num_patch = 1000;
    config.resize_factor = 2^(-1);
    
    %batch function
    fn = @(imdb,batch)getBatch(imdb,batch);
    config.getBatch = fn;
    
    %num epochs
    config.nIteration = 100;

    % sampling parameters
    config.T = 15;
    config.num_syn = 20;
    
    % standard deviation for reference model q(I/sigma^2)
    % no need to change.
    config.refsig = 1;
    config.Delta = .3; 

    % parameters for sampling
    % how many layers to learn
    config.layer_to_learn = 1;

    %MNIST parameters
    config.im_size = 48; % resize MNIST digits to this size (MNIST default is 28)

    % learning iterations for each layer
    % learning rate
    config.Gamma = 0.0003;
    %config.Gamma = 0;
    % batch size
    config.batchSize = 50;

    %generator net paramters
    %config.gen_steps = 100;
    config.Delta2 = 0.3;
    config.Gamma2 = 0.0008;
    config.refsig2 = 1;
    config.s = 0.3;
    config.real_ref = 1;
    config.cap2 = 8;
    
    % image path: where the dataset locates
    config.inPath = '/Users/mitch/Dropbox/coop ADELM/training/data/';

    % 3rd party path: where the matconvnn locates
    %config.matconvv_path = '/Users/mitch/Dropbox/DeepFRAME ELM/code/matconvnet-1.0-beta16/';
     %run(fullfile(config.matconvv_path, 'matlab', 'vl_setupnn.m'));
     
    % model path: where the deep learning model locates
    config.model_path = '/Users/mitch/Dropbox/coop ADELM/training/model/';
    config.model_name = 'imagenet-vgg-verydeep-16.mat';
     %set up empty net
    net_cpu = load([config.model_path, config.model_name]);
    net_cpu = net_cpu.net;

    % name folders for results
    config.syn_im_folder = '/Users/mitch/Dropbox/coop ADELM/training/ims_syn/';
    config.gen_im_folder = '/Users/mitch/Dropbox/coop ADELM/training/ims_gen/';
    config.trained_folder = '/Users/mitch/Dropbox/coop ADELM/training/nets/';
    
    %load data
    if strcmp(config.file_str,'digits/')
        config.digits = 0:9; %digits to be used in the model
        config.set = 'test'; %train, test, both
        %read MNIST and save results to config
        [imdb,im_mat, im_labs, mean_im] = read_MNIST(config);
        config.imdb = single(imdb);
        config.imdb_mean = imresize(mean_im,[config.im_size,config.im_size]);
        config.im_mat = im_mat;
        config.im_labs = im_labs;
        %config.mean_im = single(zeros(config.im_size));
        config.mean_im = config.imdb_mean;
        config.imdb = config.imdb - repmat(config.mean_im,[1,1,1,size(config.imdb,4)]);
    else
        %get texture patches from original image if config.process_ims=1
        if config.process_ims == 1
            process_ims([config.inPath,config.process_str],...
                [config.inPath,config.file_str],config.resize_factor,...
                    config.im_size,config.num_patch);
        end
        
        %load images from folder
        files = dir([config.inPath,config.file_str,'*.png']);
        imdb = zeros(config.im_size,config.im_size,3,length(files));
        for i = 1:length(files)
            imdb(:,:,:,i) = imread([config.inPath,config.file_str,files(i).name]);
        end

        if strcmp(config.file_str(1:3),'ivy')
            config.mean_im = single(sum(imdb,4)/size(imdb,4));
        elseif strcmp(config.file_str,'escher/')
            config.mean_im = single(128*ones(config.im_size,config.im_size,3));
        end
        %config.mean_im = zeros(config.im_size,config.im_size,3);
        config.imdb = single(imdb - repmat(config.mean_im,1,1,1,size(imdb,4))); 
    end
end

function im = getBatch(imdb, batch)
    im = imdb(:,:,:,batch) ;
end