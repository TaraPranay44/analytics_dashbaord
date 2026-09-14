<script setup lang="ts">
import { useRouter } from 'vue-router'
import { useAuthRoleStore } from '../store/authRoleStore'
import { ROUTE_PATHS } from '../constants/routeConstants'
import { UI_STRINGS } from '../constants/stringConstants'

const router = useRouter()
const authRoleStore = useAuthRoleStore()

function selectRole(role: 'CEO' | 'Manager' | 'Employee') {
  authRoleStore.setRole(role)

  if (role === 'CEO') {
    router.push(ROUTE_PATHS.DASHBOARD)
  } else {
    router.push(ROUTE_PATHS.COMING_SOON)
  }
}
</script>

<template>
  <div class="login-page">
    <div class="login-card">
      <h1>{{ UI_STRINGS.LOGIN_TITLE }}</h1>
      <p>{{ UI_STRINGS.LOGIN_SUBTITLE }}</p>

      <div class="role-buttons">
        <button @click="selectRole('CEO')">{{ UI_STRINGS.ROLE_CEO }}</button>
        <button @click="selectRole('Manager')">{{ UI_STRINGS.ROLE_MANAGER }}</button>
        <button @click="selectRole('Employee')">{{ UI_STRINGS.ROLE_EMPLOYEE }}</button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.login-page {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 100vh;
}
.login-card {
  text-align: center;
  padding: 2rem;
}
.role-buttons {
  display: flex;
  gap: 1rem;
  justify-content: center;
  margin-top: 1.5rem;
}
button {
  padding: 0.75rem 1.5rem;
  border-radius: 8px;
  border: none;
  cursor: pointer;
  font-weight: 600;
}
</style>