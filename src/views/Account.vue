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
    <div class="card-home-wrapper">
      <card
        :title="account.username"
        :subtitle="`${nbETH} Ξ\t\t${account.balance} Tokens`"
        :gradient="false"
      >
        <div class="explanations">
         informations depuis le contract : <br>
          username :{{ account.username}} <br>
          balance : {{account.balance}} <br>
          registered : {{account.registered}} <br> <br>
          Information depuis Etherium : <br>
          Contract <br>
          Address : {{address}} <br>
          Nb de ETH : {{nbETH}}
        </div>
        <div class="explanations">
          On your account on the contract, you have
          {{ account.balance }} tokens. If you click
          <button class="button-link" @click="addTokens">Add tokens</button>
        </div>
      </card>
    </div>
      <collective-button @click="goToNewProject" class='btn-primary'>
        add project
      </collective-button>
      <spacer :size="24" />
      <h2 v-if ="projectsList.length!==0">Projects List : </h2>
    <div>
      <card class ="btn-primary"
        v-for="projectList in projectsList" :key="projectList"
        :title=projectList
      >
      </card>
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
    const projectsList = ''
    return { account, username, project, projectName, projectsList }
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
    async addTokens() {
      const { contract } = this
      await contract.methods.addBalance(200).send()
      await this.updateAccount()
    },
    goToNewProject() {
      this.$router.push({ name: 'Project' })
    },
  },
  async mounted() {
    const { address, contract, projectsList } = this //you need here of account and address to get "account" objet which contains username, balance( ex : 200 tokens) and a boolean
    const account = await contract.methods.user(address).call()
    if (account.registered) this.account = account
    const projectName = await contract.methods.memberOf(address).call()
    const project = await contract.methods.project(projectName).call()
    const projetsList = await contract.methods.getProjectMapping().call()
    this.projectsList = projetsList

    if (project.registered) this.project = project
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

.btn-primary {
  margin-top: 20px;
  background-color: rgb(89, 25, 138);
  font-size: 16px;
  padding: 14px 40px;
  border-radius: 20px;
  cursor: pointer;
  text-align: center;
  /* width: 50%; */
  margin: auto;
  margin-top: 30px;
  width: 50%;
  padding: 10px;
}
</style>
