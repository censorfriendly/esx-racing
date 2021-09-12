<template>
  <div class="rapp">
        <!-- <h3 class="center-md" @click="triggerTab(0)">Underground Scene</h3> -->
        <p class="error" v-html="errmessage">
        <div class="row center-md">
            <div class="tab col-md-2 col-md-offset" :class="{active:index==0}" @click="triggerTab(0)">Home</div>
            <div class="tab col-md-3" :class="{active:index==1}" @click="triggerTab(1)">Pending Races</div>
            <div class="tab col-md-3" :class="{active:index==2}" @click="triggerTab(2)">Tracks</div>
            <div class="tab col-md-2" :class="{active:index==3}" @click="triggerTab(3)">Leaderboards</div>
        </div>
        <hr/>
        <div class="interior-page" v-dragscroll>
            <div class="loading-screen" :class="{active:loadScreen}">
                <div class="lds-spinner"><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div></div>
            </div>
            <div :class="{active:index==0}" class="screen-container">
                <homeScreen />
            </div>
            <div :class="{active:index==1}" class="screen-container">
                <pendingScreen/>
            </div>
            <div :class="{active:index==2}" class="screen-container">
                <trackScreen/>
            </div>
            <div :class="{active:index==3}" class="screen-container">
                <leaderboardScreen />
            </div>
        </div>
        <div class="rapp_currency" v-if="cryptoEnabled">
           <span v-html="cryptoName" />: <span v-html="crypto" />
        </div>
  </div>
</template>

<script>
import pendingScreen from './pendingScreen';
import leaderboardScreen from './leaderboardScreen';
import homeScreen from './homeScreen';
import trackScreen from './trackScreen';
import Nui from '../utils/Nui';
export default {
  name: 'race-app',
  components: {
      pendingScreen,
      leaderboardScreen,
      homeScreen,
      trackScreen,
  },
  props: {

  },
  data() {
    return {
      index : 0,
      loadScreen : this.$store.state.raceApp.loading
    };
  },
  methods: {
      closeApp: function() {
        Nui.send('closeApp',{})
      },
      triggerTab: function(i) {
          if(i == 0) {
            Nui.send('getArchivedList',{})
          }
          else if(i == 1){
            Nui.send('getPendingRaces',{})
            this.$store.state.raceApp.loading = true;
          }
          else if(i == 3) {
            Nui.send('getLeaderboards',{})
          }
          this.$store.state.raceApp.error = '';
          this.index = i;
          document.getElementsByClassName('interior-page')[0].scrollTop = 0;
      }
  },
  mounted() {
    Nui.send('initApp',{})
    this.listener = window.addEventListener(
      'message',
      event => {
        const item = event.data || event.detail;
        if (item.trackListEvent) {
            this.$store.state.trackList = item.tracks;
        }
        if (item.racingListEvent) {
            this.$store.state.raceApp.loading = false;
            this.$store.state.pendingList = item.list;
            this.index = 1;
        }
        if (item.error) {
            this.$store.state.raceApp.error = item.message;
        }
        if (item.initApp) {
            this.$store.state.global.identifier = item.identifier;
            this.$store.state.global.cryptoName = item.cryptoName;
            this.$store.state.global.cryptoEnabled = item.cryptoEnabled;
        }
        if (item.endRace || item.dnf) {
            this.$store.state.raceApp.joinedRace = false;
            this.$store.state.raceApp.isOwner = false;
            this.index = 0;
            Nui.send('getPendingRaces',{})
        }
        if (item.startrace) {  
            this.index = 0;
        }
        if (item.cryptoEvent) {
          this.$store.state.crypto = item.crypto;
        }
      },
      false,
    );
  },
  computed: {
    errmessage: function() {
      return this.$store.state.raceApp.error;
    },
    crypto: function() {
      return this.$store.state.crypto;
    },
    cryptoName: function() {
      return this.$store.state.global.cryptoName;
    },
    cryptoEnabled: function() {
      if(this.$store.state.global.cryptoEnabled) {
        return true;
      }
      return false;
      // return this.$store.state.global.cryptoEnabled;
    }
  }

};
</script>

<style lang="scss">

</style>
