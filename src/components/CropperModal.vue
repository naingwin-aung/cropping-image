<template>
  <div class="fixed z-50 h-full">
    <div class="fixed inset-0 bg-black bg-opacity-60"></div>
    <div class="fixed inset-0 z-10 overflow-auto h-full">
      <div class="flex flex-col min-h-full justify-center items-center py-2">
        <div
          class="transform overflow-hidden rounded-lg bg-white shadow-2xl transition-all max-w-lg w-full"
        >
          <div class="flex items-center py-4 border-b border-b-gray-300">
            <div class="text-[22px] font-semibold w-full text-center">
              Choose Image
            </div>
            <div
              @click="$emit('close', false)"
              class="absolute right-3 rounded-full p-1.5 bg-gray-200 hover:bg-gray-300 cursor-pointer"
            >
              Close
            </div>
          </div>

          <div class="flex items-center bg-white px-4 pb-4">
            <div class="w-full">
              <div v-if="!uploadedImage" class="my-4">
                <label
                  for="file"
                  class="flex items-center justify-center w-full py-3 rounded-full text-white font-semibold bg-black hover:bg-[#2d2b2e] mb-2 cursor-pointer"
                >
                  Upload photo
                </label>
                <input
                  type="file"
                  id="file"
                  accept="image/*" 
                  capture="environment"
                  class="hidden"
                  @change="getUploadedImage"
                />
              </div>

              <div v-if="!uploadedImage && video && video.paused" class="my-4">
                <button
                  @click="startCamera()"
                  class="flex items-center justify-center w-full py-3 rounded-full text-white font-semibold bg-black hover:bg-[#2d2b2e] mb-2 cursor-pointer"
                >
                  Open camera
                </button>
              </div>

              <div v-show="!uploadedImage && isOpenCamera" class="pb-4">
                <video autoplay v-show="!isNewPhoto" ref="video" class="aspect-square"/>
                <canvas
                  v-show="isNewPhoto"
                  ref="canvas"
                  class="aspect-square"
                />
              </div>

              <div class="max-w-lg w-full mx-auto">
                <Cropper
                  class="object-cover"
                  ref="cropper"
                  :stencil-props="{
                    movable: true,
                    resizable: true,
                    aspectRatio: 1,
                  }"
                  :resize-image="{
                    adjustStencil: false,
                  }"
                  image-restriction="stencil"
                  :src="uploadedImage"
                />
              </div>

              <div class="flex gap-4" :class="uploadedImage ? 'pt-4' : ''">
                <button
                  @click="$emit('close', false)"
                  type="button"
                  class="flex items-center border justify-center w-full py-3 rounded-full text-black font-semibold hover:bg-gray-100 focus:outline-none focus:ring-0 cursor-pointer"
                >
                  Cancel
                </button>
                <button
                  v-if="isOpenCamera"
                  @click="takePhoto()"
                  class="flex items-center justify-center w-full py-3 rounded-full text-white font-semibold bg-black hover:bg-[#2d2b2e] cursor-pointer focus:outline-none focus:ring-0"
                >
                  <span v-show="!isTakingPhoto">Take photo</span>
                  <span v-show="isTakingPhoto">Loading...</span>
                </button>
                <button
                  v-if="uploadedImage"
                  @click="cropImage()"
                  class="flex items-center justify-center w-full py-3 rounded-full text-white font-semibold bg-black hover:bg-[#2d2b2e] cursor-pointer focus:outline-none focus:ring-0"
                >
                  <span v-show="!isCropping">Crop Image</span>
                  <span v-show="isCropping">Loading...</span>
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import {ref, onUnmounted} from 'vue';
import { Cropper } from "vue-advanced-cropper";
import "vue-advanced-cropper/dist/style.css";

const emit = defineEmits(["close", "data"]);

let file = ref(null);
let video = ref(null);
let canvas = ref(null);
let isNewPhoto = ref(null);
let isOpenCamera = ref(null);
let photoData = ref(null);
let cropper = ref(null);
let uploadedImage = ref(null);
let isTakingPhoto = ref(false);
let isCropping = ref(false);

const getUploadedImage = (e) => {
  file.value = e.target.files[0];
  uploadedImage.value = URL.createObjectURL(e.target.files[0]);
};

const startCamera = async () => {
  isOpenCamera.value = true;

  if (navigator.mediaDevices) {
    let stream = await navigator.mediaDevices.getUserMedia({
      video: {
        width: { max: 1024 },
        height: { max: 1024 },
        aspectRatio: { ideal: 1 },
        facingMode: 'user'
      },
    });
    video.value.srcObject = stream;
    video.value.play();

    video.value.style.transform = 'scaleX(-1)';
  }
};

const takePhoto = () => {
  let videoLocal = video.value;
  let canvasLocal = canvas.value;

  canvasLocal.width = videoLocal.getBoundingClientRect().width;
  canvasLocal.height = videoLocal.getBoundingClientRect().height;

  let context = canvasLocal.getContext("2d");
  context.imageSmoothingEnabled = true;
  context.imageSmoothingQuality = 'high';
  context.scale(-1, 1);
  context.drawImage(videoLocal, -canvasLocal.width, 0, canvasLocal.width, canvasLocal.height);
  context.setTransform(1, 0, 0, 1, 0, 0);

  isNewPhoto.value = true;
  photoData.value = canvasLocal.toDataURL();

  convertBlobToUrl();
};

const convertBlobToUrl = async () => {
  const blob = await (await fetch(photoData.value)).blob();
  file.value = new File([blob], "NEW_PHOTO.png", { type: blob.type });
  uploadedImage.value = URL.createObjectURL(file.value);
  isOpenCamera.value = false;
};

const cropImage = async () => {
  isCropping.value = true;
  const { coordinates } = cropper.value.getResult();

  let data = new FormData();
  data.append("image", file.value || "");
  data.append("height", coordinates.height || "");
  data.append("width", coordinates.width || "");
  data.append("left", coordinates.left || "");
  data.append("top", coordinates.top || "");

  isCropping.value = true;
  emit("data", data);
};

onUnmounted(() => {
    if(video.value) {
        video.value.pause();
        video.value.currentTime = 0;
    }
});
</script>
