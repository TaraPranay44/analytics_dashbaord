<script setup lang="ts">
import { ref } from 'vue'

const username = ref('')
const password = ref('')
function handleLogin() {
  console.log('Username:', username.value)
  console.log('Password:', password.value)
}
</script>
<template>
  <div class="login-page">
    <div class="login-card">
      <h1>Employee Analytics Portal</h1>
      <p>Sign in to continue</p>

      <label>Username</label>
      <input
        type="text"
        placeholder="Enter your username"
        v-model="username"
      />
    
      <label>Password</label>
      <input
        type="password"
        placeholder="Enter your password"
        v-model="password"
      />
      <button @click="handleLogin">Login</button>
    </div>
  </div>
</template>

<style scoped>
.login-page {
  min-height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
}
.login-card h1 {
  color: #111827;
}

.login-card {
  width:90%;  
  max-width:400px;
  padding: 40px;
  text-align: center;
  background: #ffffff;
  border-radius: 12px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
  color: #111827;
}

.login-card input {
  display: block;
  width: 100%;
  margin: 12px 0;
  padding: 12px;
  border-radius: 6px;
  box-sizing: border-box;
}

.login-card button {
  width: 100%;
  padding: 12px;
  margin-top: 10px;
  border-radius: 6px;
  cursor: pointer;
  background: #2563eb;
}
.login-card button:hover {
  opacity: 0.85;
}
.login-card h1 {
  font-size: 32px;
  line-height: 1.2;
  margin-bottom: 10px;
}
.login-card label {
  display: block;
  text-align: left;
  margin-top: 12px;
}

</style>