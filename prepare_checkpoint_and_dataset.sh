#!/bin/bash

# Exit script on error.
set -e
# Echo each command, easier for debugging.
set -x

usage() {
  cat << END_OF_USAGE
  Downloads checkpoint and dataset needed for the tutorial.

  --network_type      Can be one of [mobilenet_v1_ssd, mobilenet_v2_ssd],
                      mobilenet_v1_ssd by default.
  --train_whole_model Whether or not to train all layers of the model. false
                      by default, in which only the last few layers are trained.
  --help              Display this help.
END_OF_USAGE
}

network_type="mobilenet_v2_ssd"
train_whole_model="true"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --network_type)
      network_type=$2
      shift 2 ;;
    --train_whole_model)
      train_whole_model=$2
      shift 2;;
    --help)
      usage
      exit 0 ;;
    --*)
      echo "Unknown flag $1"
      usage
      exit 1 ;;
  esac
done

source "$PWD/constants.sh"

echo "PREPARING checkpoint..."
mkdir -p "${LEARN_DIR}"

ckpt_link="${ckpt_link_map[${network_type}]}"
ckpt_name="${ckpt_name_map[${network_type}]}"
cd "${LEARN_DIR}"
wget -O "${ckpt_name}.zip" "$ckpt_link"
tar zxvf "${ckpt_name}.zip"
mv "${ckpt_name}" "${CKPT_DIR}"

echo "CHOSING config file..."
config_filename="${config_filename_map[${network_type}-${train_whole_model}]}"
cd "${OBJ_DET_DIR}"
cp "configs/${config_filename}" "${CKPT_DIR}/pipeline.config"

echo "REPLACING variables in config file..."
sed -i "s%CKPT_DIR_TO_CONFIGURE%${CKPT_DIR}%g" "${CKPT_DIR}/pipeline.config"
sed -i "s%DATASET_DIR_TO_CONFIGURE%${DATASET_DIR}%g" "${CKPT_DIR}/pipeline.config"

######################### PREPARE DATASET ORIGINAL ##################################

echo "PREPARING dataset --> ORIGINAL WAY"
#mkdir "${DATASET_DIR}"
#cd "${DATASET_DIR}"
#wget http://images.cocodataset.org/zips/train2017.zip
#wget http://images.cocodataset.org/annotations/annotations_trainval2017.zip
#unzip train2017.zip
#unzip annotations_trainval2017.zip

######################### PREPARE DATASET INNOVATIVE ##################################

echo "PREPARING dataset --> INNOVATIVE WAY"
. ./object_detection/dataset_tools/download_and_preprocess_mscoco.sh


#echo "PREPARING dataset using first two classes of Oxford-IIIT Pet dataset..."
# Extract first two classes of data
#cp "${DATASET_DIR}/annotations/list.txt" "${DATASET_DIR}/annotations/list_petsdataset.txt"
#cp "${DATASET_DIR}/annotations/trainval.txt" "${DATASET_DIR}/annotations/trainval_petsdataset.txt"
#cp "${DATASET_DIR}/annotations/test.txt" "${DATASET_DIR}/annotations/test_petsdataset.txt"
#grep "Abyssinian" "${DATASET_DIR}/annotations/list_petsdataset.txt" >  "${DATASET_DIR}/annotations/list.txt"
#grep "american_bulldog" "${DATASET_DIR}/annotations/list_petsdataset.txt" >> "${DATASET_DIR}/annotations/list.txt"
#grep "Abyssinian" "${DATASET_DIR}/annotations/trainval_petsdataset.txt" > "${DATASET_DIR}/annotations/trainval.txt"
#grep "american_bulldog" "${DATASET_DIR}/annotations/trainval_petsdataset.txt" >> "${DATASET_DIR}/annotations/trainval.txt"
#grep "Abyssinian" "${DATASET_DIR}/annotations/test_petsdataset.txt" > "${DATASET_DIR}/annotations/test.txt"
#grep "american_bulldog" "${DATASET_DIR}/annotations/test_petsdataset.txt" >> "${DATASET_DIR}/annotations/test.txt"

echo "PREPARING label map..."
cd "${OBJ_DET_DIR}"
cp "object_detection/data/mscoco_label_map.pbtxt" "${DATASET_DIR}"

echo "CONVERTING dataset to TF Record..."
python object_detection/dataset_tools/create_coco_coco_record.py \
    --label_map_path="${DATASET_DIR}/mscoco_label_map.pbtxt" \
    --data_dir="${DATASET_DIR}" \
    --output_dir="${DATASET_DIR}"