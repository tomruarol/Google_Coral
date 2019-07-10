# Re-Train Cocos model based datatse

This file explain the steps followed to Re-Train the model with fewer classes (just 5) in order to seek for model performance improvement.

The changes made are:

1) Change the label file:

Under the location of:

    tensorflow/models/research/object_detection/data

The file:

    mscoco_label_map.pbtxt

- Just delete all the not needed classes/id's and leave the 5 needed (this is person, and vehicles ones).


From the file to prepare the checkpoint and the dataset