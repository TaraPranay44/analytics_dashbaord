import { createApp } from 'vue'
import { createPinia } from 'pinia'
import { VueQueryPlugin } from '@tanstack/vue-query'
import { FrappeUI, setConfig, frappeRequest } from 'frappe-ui'
import './style.css'
import App from './App.vue'
import router from './router'

const app = createApp(App)

app.use(FrappeUI)
setConfig('resourceFetcher', frappeRequest)

app.use(createPinia())
app.use(VueQueryPlugin)
app.use(router)

app.mount('#app')