import { createRouter, createWebHistory, RouteRecordRaw } from 'vue-router'
import store from '@/store'
import SignIn from '@/views/SignIn.vue'

const routes: Array<RouteRecordRaw> = [
  {
    path: '/',
    name: 'SignIn',
    component:() => import('@/views/SignIn.vue'),
  },
  {
    path: '/account',
    name: 'Account',
    component: () => import('@/views/Account.vue'),
  },
  {
    path: '/company-signin',
    name: 'CompanySignIn',
    component: () => import('@/views/CompanySignIn.vue'),
  },
  {
    path: '/company',
    name: 'Company',
    component: () => import('@/views/Company.vue'),
  },
  {
    path: '/project',
    name: 'Project',
    component: () => import('@/views/Project.vue'),
  },
]

const router = createRouter({
  history: createWebHistory(process.env.BASE_URL),
  routes,
})

// router.beforeEach((to, _from, next) => {
//   if (to.name !== 'SignIn' && !store.state.account.address) {
//     next({ name: 'SignIn' })
//   } else {
//     next()
//   }
// })

export default router
