# Re-Train Cocos model based datatse

This file explain the steps followed to Re-Train the model with fewer classes (just 5) in order to seek for model performance improvement.

The changes made are:

1) Change the label file:

    Under the location of:

    *tensorflow/models/research/object_detection/data*

    The file:

    *mscoco_label_map.pbtxt*

- Just delete all the not needed classes/id's and leave the 5 needed (this is person, and vehicles ones).


2) From the file to prepare the checkpoint and the dataset:

    Under the location:

    *tensorflow/models/research/*

    The file:

    *prepare_checkpoint_and_dataset.sh*

- Change:

    - network_type
    - train_whole_model
    - ${DATASET_DIR}
    - The file to convert it al to TFRecord: *create_coco_tf_record.py*

    - A couple more things might have to be changed, but those are the fundamental ones.

4) Define the paths under the *pipeline,py* file and change a couple of things in that script.

5) Finally, set the variables to train the whole model:

        NUM_TRAINING_STEPS=50000 && \
        NUM_EVAL_STEPS=2000

6) Start the training job:

        
        # From the /tensorflow/models/research/ directory
        ./retrain_detection_model.sh \
        --num_training_steps ${NUM_TRAINING_STEPS} \
        --num_eval_steps ${NUM_EVAL_STEPS}


**To monitor the process:**
 
1) Start bash in a separate terminal to join the same Docker container.

        sudo docker exec -it edgetpu-detect /bin/bash

2) In the new Docker terminal, execute the following command to start tensorboard in /tensorflow/models/research/ directory. After you execute the command, tensorboard visualizes the model accuracy throughout training in your local machine's browser at http://localhost:6006/.

        tensorboard --logdir=./learn_pet/train/

As training progresses, you can see the transfer-learned checkpoint files begin to appear in the */tensorflow/models/research/learn_pet/train* directory.