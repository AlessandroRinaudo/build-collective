<template lang="html">
  <div class="home" v-if="!account">
    <form @submit.prevent="signUp">
      <card
        title="Enter your username here"
        subtitle="Type directly in the input and hit enter. All spaces will be converted to _"
      >
        <input
          type="text"
          class="input-username"
          v-model="username"
          placeholder="Type your username here"
        />
      </card>
    </form>
  </div>

  <div class="home" v-if="account">

    <div class="home" v-if="!project">
    <form @submit.prevent="createProject">
      <card
        title="Enter your project name here"
        subtitle="Type directly in the input and hit enter. All spaces will be converted to _"
      >
        <input
          type="text"
          class="input-username"
          v-model="projectName"
          placeholder="Type your project name here"
        />
      </card>
    </form>
</div>
    <div class="home" v-if="project">
 <div class="card-home-wrapper">
      <card
        :title="project.name"
        :subtitle="`Owner : ${project.user_owner.username}`"
        :gradient="false"
      >
       <div class="explanations">
          Project name : {{ project.name}} <br>
          Project owner : {{ project.user_owner.username}} <br>
          balance : {{project.balance}} <br>
          registered : {{project.registered}} <br> <br>
          Members : {{ project.members}} <br>
         
        </div>
        <div class="explanations">
          On your project on the contract, you have
          {{ project.balance }} tokens. If you click
          <button class="button-link" @click="addProjectBalance()">Add tokens</button>
        </div>
      </card>

      <form @submit.prevent="addProjectMember">
        <card
          title="Enter the new member address"
        >
          <input
            type="text"
            class="input-username"
            v-model="memberAddress"
            placeholder="Type a member address"
          />
        </card>
      </form>
    </div>
    </div>
    

  </div>
</template>

<script lang="ts">
import { defineComponent, computed } from 'vue'
import { useStore } from 'vuex'
import Card from '@/components/Card.vue'

export default defineComponent({
  components: { Card },
  setup() {
    const store = useStore()
    const contract = computed(() => store.state.contract) // take the contract  !REQUIRED TO CONNECTION
    const address = computed(() => store.state.account.address) // take the address !REQUIRED TO CONNECTION
    const nbETH = computed(() => store.state.account.nbETH) // take the account balance ex: 100 eth  account.balance != balance
    return { address, contract, nbETH }
  },
  data() {
    const account = null
    const username = ''
    const project = null
    const projectName = ''
    const memberAddress = ''
    return { account, username, project, projectName, memberAddress }
  },
  methods: {
    async updateAccount() {
      const { address, contract } = this
      this.account = await contract.methods.user(address).call()
    },
    async signUp() {
      const { contract, username } = this
      const name = username.trim().replace(/ /g, '_')
      await contract.methods.signUp(name).send()
      await this.updateAccount()
      this.username = ''
    },
    async addProjectBalance() {
      const { contract } = this
      await contract.methods.addBalanceToProject(200,true).send()
      await this.updateProject()
    },
    async updateProject() {
      const { projectName, contract } = this
      this.project = await contract.methods.project(projectName).call()
    },
    async createProject() {
      const { contract, projectName } = this
      const name = projectName.trim().replace(/ /g, '_')
      await contract.methods.createProject(name,true).send()
      await this.updateProject()
      this.projectName = ''
    },
    async addProjectMember() {
      const { contract,address,memberAddress } = this
      const projectName = await contract.methods.memberOf(address).call()
      const name = projectName.name.trim().replace(/ /g, '_')
      console.log('debug', name, memberAddress)

      await contract.methods.addProjectMember(name, memberAddress).send()
      await this.updateProject()
      this.projectName = ''
    },
  },
  async mounted() {
    const { address, contract } = this //you need here of account and address to get "account" objet which contains username, balance( ex : 200 tokens) and a boolean
    const account = await contract.methods.user(address).call()
    const projectName = await contract.methods.memberOf(address).call()
    const project = await contract.methods.project(projectName.name).call()
    if (account.registered) this.account = account
    if (project.registered)
      this.project = project
  },
})
</script>


































<style lang="css" scoped>
.home {
  padding: 24px;
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
  max-width: 500px;
  margin: auto;
}

.explanations {
  padding: 12px;
}

.button-link {
  display: inline;
  appearance: none;
  border: none;
  background: none;
  color: inherit;
  text-decoration: underline;
  font-family: inherit;
  font-size: inherit;
  font-weight: inherit;
  padding: 0;
  margin: 0;
  cursor: pointer;
}

.input-username {
  background: transparent;
  border: none;
  padding: 12px;
  outline: none;
  width: 100%;
  color: white;
  font-family: inherit;
  font-size: 1.3rem;
}
</style>
