<script setup lang="ts">
import { UI_STRINGS } from '../constants/stringConstants'
</script>

<template>
  <div class="coming-soon">
    <h1>{{ UI_STRINGS.COMING_SOON_TITLE }}</h1>
    <p>{{ UI_STRINGS.COMING_SOON_MESSAGE }}</p>
  </div>
</template>

<style scoped>
.coming-soon {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100vh;
  text-align: center;
}
</style>