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

    <div class="home" v-if="!company">
    <form @submit.prevent="createCompany">
      <card
        title="Enter your company name here"
        subtitle="Type directly in the input and hit enter. All spaces will be converted to _"
      >
        <input
          type="text"
          class="input-username"
          v-model="companyName"
          placeholder="Type your company name here"
        />
      </card>
    </form>
</div>
    <div class="home" v-if="company">
 <div class="card-home-wrapper">
      <card
        :title="company.name"
        :subtitle="`${nbETH} Ξ\t\t${company.owner.username}`"
        :gradient="false"
      >
       
      </card>
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
    const company = null
    const companyName = ''
    return { account, username, company, companyName }
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
    async updateCompany() {
      const { address, contract } = this
      this.company = await contract.methods.company(address).call()
    },
    async createCompany() {
      const { contract, companyName } = this
      const name = companyName.trim().replace(/ /g, '_')
      await contract.methods.createCompany(name).send()
      await this.updateCompany()
      this.companyName = ''
    },
  },
  async mounted() {
    const { address, contract,companyName } = this //you need here of account and address to get "account" objet which contains username, balance( ex : 200 tokens) and a boolean
    console.log("companyName",companyName);
    const account = await contract.methods.user(address).call()
    const company = await contract.methods.company("Generalisol").call()
    if (account.registered) this.account = account
    if (company.registered && company.owner.username===account.username) this.company = company
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
