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
    <form @submit.prevent="createcompany">
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
        :subtitle="`Owner : ${company.owner.username}`"
        :gradient="false"
      >
       <div class="explanations">
          company name : {{ company.name}} <br>
          company owner : {{ company.owner.username}} <br>
          balance : {{company.balance}} <br>
          registered : {{company.registered}} <br> <br>
          Members : {{ company.members}} <br>

        </div>
        <div class="explanations">
          On your company on the contract, you have
          {{ company.balance }} tokens. If you click
          <button class="button-link" @click="addcompanyBalance()">Add tokens</button>
        </div>
      </card>

      <form @submit.prevent="addcompanyMember">
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
    const company = null
    const companyName = ''
    const memberAddress = ''
    return { account, username, company, companyName, memberAddress }
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
    async addcompanyBalance() {
      const { contract } = this
      await contract.methods.addCompanyBalance(200).send()
      await this.updatecompany()
    },

    async updatecompany() {
      const { address, contract } = this
      const companyName = await contract.methods.memberOf(address).call()
      this.company = await contract.methods.getCompanie(companyName).call()
      console.log('update', companyName, this.company, address)

    },
    async createcompany() {
      const { contract, companyName } = this
      const name = companyName.trim().replace(/ /g, '_')
      await contract.methods.createCompany(name).send()
      await this.updatecompany()
      this.companyName = ''
      console.log('Create', companyName, this.company)

    },
    async addcompanyMember() {
      const { contract,address,memberAddress } = this
      const companyName = await contract.methods.memberOf(address).call()
      // const comp = await contract.methods.company(companyName).call()
      const name = companyName.trim().replace(/ /g, '_')
      console.log('debug', name, memberAddress)

      await contract.methods.addCompanyMember(name, memberAddress).send()
      await this.updatecompany()
      console.log('debug', this.company)

      this.companyName = ''
    },
  },
  async mounted() {
    const { address, contract } = this //you need here of account and address to get "account" objet which contains username, balance( ex : 200 tokens) and a boolean
    const account = await contract.methods.user(address).call()
    const companyName = await contract.methods.memberOf(address).call()
    const company = await contract.methods.getCompanie(companyName).call()
    if (account.registered) this.account = account
    console.log('mounted', companyName, company)
    if (company.registered && company.owner.username === account.username)
      this.company = company
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
