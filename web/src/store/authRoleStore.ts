import { defineStore } from 'pinia'

export const useAuthRoleStore = defineStore('authRole', {
  state: () => ({
    selectedRole: null as 'CEO' | 'Manager' | 'Employee' | null,
  }),
  actions: {
    setRole(role: 'CEO' | 'Manager' | 'Employee') {
      this.selectedRole = role
    },
  },
})