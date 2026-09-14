import { createRouter, createWebHistory } from 'vue-router'
import { ROUTE_NAMES, ROUTE_PATHS } from '../constants/routeConstants'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: ROUTE_PATHS.LOGIN,
      name: ROUTE_NAMES.LOGIN,
      component: () => import('../views/LoginView.vue'),
    },
    {
      path: ROUTE_PATHS.DASHBOARD,
      name: ROUTE_NAMES.DASHBOARD,
      component: () => import('../views/DashboardView.vue'),
    },
    {
      path: ROUTE_PATHS.EMPLOYEE_DETAIL,
      name: ROUTE_NAMES.EMPLOYEE_DETAIL,
      component: () => import('../views/EmployeeDetailView.vue'),
    },
    {
      path: ROUTE_PATHS.COMING_SOON,
      name: ROUTE_NAMES.COMING_SOON,
      component: () => import('../views/ComingSoonView.vue'),
    },
    {
      path: ROUTE_PATHS.ORG_HIERARCHY,
      name: ROUTE_NAMES.ORG_HIERARCHY,
      component: () => import('../views/OrgHierarchyPageView.vue'),
    },
  ],
})

export default router