<template>
  <button @click="openCropper = true" class="border m-10 px-10 py-5 border-gray-500 bg-slate-700 text-white">
    Change
  </button>
  <CropperModal v-if="openCropper" @data="data = $event" @close="openCropper = $event"/>
</template>

<script setup>
import CropperModal from './components/CropperModal.vue';
import {ref, watch} from 'vue';

const openCropper = ref(false);
const data = ref(null);

watch(() => data.value, () => {
  console.log(data.value);
})

</script>

<style lang="scss" scoped>

</style>