<template>
  <div class="rapp">
        <h1 @click="index = 0 ">Home Screen</h1>
        <p class="error" v-html="errmessage">
        <hr/>
        <div class="grid third center">
            <div class="tab" :class="{active:index==1}" @click="triggerTab(1)">Pending Races</div>
            <div class="tab" :class="{active:index==2}" @click="triggerTab(2)">Tracks</div>
            <div class="tab" :class="{active:index==3}" @click="triggerTab(3)">Leaderboards</div>
        </div>
        <div class="interior-page">
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
      errmessage: '',
      loadScreen : this.$store.state.raceApp.loading
    };
  },
  methods: {
      closeApp: function() {
        Nui.send('closeApp',{})
      },
      triggerTab: function(i) {
          if(i == 1){
            Nui.send('getPendingRaces',{})
            this.$store.state.raceApp.loading = true;
          }
          this.index = i;
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
            console.log(item.list);
            this.$store.state.pendingList = item.list;
        }
        if (item.error) {
            this.errmessage = item.message;
        }
        if (item.initApp) {
            this.$store.state.global.identifier = item.identifier;
        }
        if (item.endRace) {
            this.$store.state.raceApp.joinedRace = false;
            this.$store.state.raceApp.race_id = 0;
            this.index = 0;
            Nui.send('getPendingRaces',{})
        }
        if (item.startrace) {  
            this.index = 0;
        }
      },
      false,
    );
  },

};
</script>

<style lang="scss">
.rapp {
    display: none;
    background-color: green;
    position: absolute;
    bottom:0px;
    right:0px;
    padding:15px;
    min-height: 25%;
    min-width: 400px;
    h1 {
      text-align: center;
    }
    .interior-page {
        height: 500px;
        overflow-y:auto;
        position: relative;
    }
    .loading-screen {
        width:100%;
        height: 100%;
        position: absolute;
        opacity: 0;
        transition: .5s;
        visibility: hidden;
        &.active {
            visibility: visible;
            opacity: 1;
        }
    }
    .screen-container {
      position: absolute;
      top:0px;
      left:0px;
      visibility: hidden;
      opacity: 0;
      transition: all .5s;
      &.active {
        visibility: visible;
        opacity: 1;
      }
    }
}
.tab {
    cursor: pointer;
    &.active {
        background-color: black;
        color: white;
    }
}
.error {
    color:red;
}



// Loader css
.lds-spinner {
    color: official;
    display: inline-block;
    position: absolute;
    width: 80px;
    height: 80px;
    left: 50%;
    top: 50%;
    transform: translate(-40px, -40px);
}
.lds-spinner div {
  transform-origin: 40px 40px;
  animation: lds-spinner 1.2s linear infinite;
}
.lds-spinner div:after {
  content: " ";
  display: block;
  position: absolute;
  top: 3px;
  left: 37px;
  width: 6px;
  height: 18px;
  border-radius: 20%;
  background: #fff;
}
.lds-spinner div:nth-child(1) {
  transform: rotate(0deg);
  animation-delay: -1.1s;
}
.lds-spinner div:nth-child(2) {
  transform: rotate(30deg);
  animation-delay: -1s;
}
.lds-spinner div:nth-child(3) {
  transform: rotate(60deg);
  animation-delay: -0.9s;
}
.lds-spinner div:nth-child(4) {
  transform: rotate(90deg);
  animation-delay: -0.8s;
}
.lds-spinner div:nth-child(5) {
  transform: rotate(120deg);
  animation-delay: -0.7s;
}
.lds-spinner div:nth-child(6) {
  transform: rotate(150deg);
  animation-delay: -0.6s;
}
.lds-spinner div:nth-child(7) {
  transform: rotate(180deg);
  animation-delay: -0.5s;
}
.lds-spinner div:nth-child(8) {
  transform: rotate(210deg);
  animation-delay: -0.4s;
}
.lds-spinner div:nth-child(9) {
  transform: rotate(240deg);
  animation-delay: -0.3s;
}
.lds-spinner div:nth-child(10) {
  transform: rotate(270deg);
  animation-delay: -0.2s;
}
.lds-spinner div:nth-child(11) {
  transform: rotate(300deg);
  animation-delay: -0.1s;
}
.lds-spinner div:nth-child(12) {
  transform: rotate(330deg);
  animation-delay: 0s;
}
@keyframes lds-spinner {
  0% {
    opacity: 1;
  }
  100% {
    opacity: 0;
  }
}

</style>
