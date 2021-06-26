<template>
  <div class="rapp">
        <h1 @click="triggerTab(0)">Home Screen</h1>
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
          else if(i == 0) {
            console.log("sending archived list request");
            Nui.send('getArchivedList',{})
          }
          this.$store.state.raceApp.error = '';
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
            this.$store.state.pendingList = item.list;
        }
        if (item.error) {
            this.$store.state.raceApp.error = item.message;
        }
        if (item.initApp) {
            this.$store.state.global.identifier = item.identifier;
        }
        if (item.endRace) {
            this.$store.state.raceApp.joinedRace = false;
            this.$store.state.raceApp.isOwner = false;
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
  computed: {
    errmessage: function() {
      return this.$store.state.raceApp.error;
    }
  }

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
    max-width: 400px;
    width: 400px;
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
      width:100%;
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


// Custom animations
.expand-height {
  max-height: 0px;
  overflow: hidden;
  transition: max-height .5s ease-in-out;
  &.active {
    max-height: 1000px;
  }
}
.togglable {
  cursor: pointer;
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

// Grid

.container-fluid,
.container {
  margin-right: auto;
  margin-left: auto;
}

.container-fluid {
  padding-right: 2rem;
  padding-left: 2rem;
}

.row {
  box-sizing: border-box;
  display: -webkit-box;
  display: -ms-flexbox;
  display: flex;
  -webkit-box-flex: 0;
  -ms-flex: 0 1 auto;
  flex: 0 1 auto;
  -webkit-box-orient: horizontal;
  -webkit-box-direction: normal;
  -ms-flex-direction: row;
  flex-direction: row;
  -ms-flex-wrap: wrap;
  flex-wrap: wrap;
  margin-right: -0.5rem;
  margin-left: -0.5rem;
}

.row.reverse {
  -webkit-box-orient: horizontal;
  -webkit-box-direction: reverse;
  -ms-flex-direction: row-reverse;
  flex-direction: row-reverse;
}

.col.reverse {
  -webkit-box-orient: vertical;
  -webkit-box-direction: reverse;
  -ms-flex-direction: column-reverse;
  flex-direction: column-reverse;
}

.col-xs,
.col-xs-1,
.col-xs-2,
.col-xs-3,
.col-xs-4,
.col-xs-5,
.col-xs-6,
.col-xs-7,
.col-xs-8,
.col-xs-9,
.col-xs-10,
.col-xs-11,
.col-xs-12,
.col-xs-offset-0,
.col-xs-offset-1,
.col-xs-offset-2,
.col-xs-offset-3,
.col-xs-offset-4,
.col-xs-offset-5,
.col-xs-offset-6,
.col-xs-offset-7,
.col-xs-offset-8,
.col-xs-offset-9,
.col-xs-offset-10,
.col-xs-offset-11,
.col-xs-offset-12 {
  box-sizing: border-box;
  -webkit-box-flex: 0;
  -ms-flex: 0 0 auto;
  flex: 0 0 auto;
  padding-right: 0.5rem;
  padding-left: 0.5rem;
}

.col-xs {
  -webkit-box-flex: 1;
  -ms-flex-positive: 1;
  flex-grow: 1;
  -ms-flex-preferred-size: 0;
  flex-basis: 0;
  max-width: 100%;
}

.col-xs-1 {
  -ms-flex-preferred-size: 8.33333333%;
  flex-basis: 8.33333333%;
  max-width: 8.33333333%;
}

.col-xs-2 {
  -ms-flex-preferred-size: 16.66666667%;
  flex-basis: 16.66666667%;
  max-width: 16.66666667%;
}

.col-xs-3 {
  -ms-flex-preferred-size: 25%;
  flex-basis: 25%;
  max-width: 25%;
}

.col-xs-4 {
  -ms-flex-preferred-size: 33.33333333%;
  flex-basis: 33.33333333%;
  max-width: 33.33333333%;
}

.col-xs-5 {
  -ms-flex-preferred-size: 41.66666667%;
  flex-basis: 41.66666667%;
  max-width: 41.66666667%;
}

.col-xs-6 {
  -ms-flex-preferred-size: 50%;
  flex-basis: 50%;
  max-width: 50%;
}

.col-xs-7 {
  -ms-flex-preferred-size: 58.33333333%;
  flex-basis: 58.33333333%;
  max-width: 58.33333333%;
}

.col-xs-8 {
  -ms-flex-preferred-size: 66.66666667%;
  flex-basis: 66.66666667%;
  max-width: 66.66666667%;
}

.col-xs-9 {
  -ms-flex-preferred-size: 75%;
  flex-basis: 75%;
  max-width: 75%;
}

.col-xs-10 {
  -ms-flex-preferred-size: 83.33333333%;
  flex-basis: 83.33333333%;
  max-width: 83.33333333%;
}

.col-xs-11 {
  -ms-flex-preferred-size: 91.66666667%;
  flex-basis: 91.66666667%;
  max-width: 91.66666667%;
}

.col-xs-12 {
  -ms-flex-preferred-size: 100%;
  flex-basis: 100%;
  max-width: 100%;
}

.col-xs-offset-0 {
  margin-left: 0;
}

.col-xs-offset-1 {
  margin-left: 8.33333333%;
}

.col-xs-offset-2 {
  margin-left: 16.66666667%;
}

.col-xs-offset-3 {
  margin-left: 25%;
}

.col-xs-offset-4 {
  margin-left: 33.33333333%;
}

.col-xs-offset-5 {
  margin-left: 41.66666667%;
}

.col-xs-offset-6 {
  margin-left: 50%;
}

.col-xs-offset-7 {
  margin-left: 58.33333333%;
}

.col-xs-offset-8 {
  margin-left: 66.66666667%;
}

.col-xs-offset-9 {
  margin-left: 75%;
}

.col-xs-offset-10 {
  margin-left: 83.33333333%;
}

.col-xs-offset-11 {
  margin-left: 91.66666667%;
}

.start-xs {
  -webkit-box-pack: start;
  -ms-flex-pack: start;
  justify-content: flex-start;
  text-align: start;
}

.center-xs {
  -webkit-box-pack: center;
  -ms-flex-pack: center;
  justify-content: center;
  text-align: center;
}

.end-xs {
  -webkit-box-pack: end;
  -ms-flex-pack: end;
  justify-content: flex-end;
  text-align: end;
}

.top-xs {
  -webkit-box-align: start;
  -ms-flex-align: start;
  align-items: flex-start;
}

.middle-xs {
  -webkit-box-align: center;
  -ms-flex-align: center;
  align-items: center;
}

.bottom-xs {
  -webkit-box-align: end;
  -ms-flex-align: end;
  align-items: flex-end;
}

.around-xs {
  -ms-flex-pack: distribute;
  justify-content: space-around;
}

.between-xs {
  -webkit-box-pack: justify;
  -ms-flex-pack: justify;
  justify-content: space-between;
}

.first-xs {
  -webkit-box-ordinal-group: 0;
  -ms-flex-order: -1;
  order: -1;
}

.last-xs {
  -webkit-box-ordinal-group: 2;
  -ms-flex-order: 1;
  order: 1;
}

@media only screen and (min-width: 48em) {
  .container {
    width: 49rem;
  }

  .col-sm,
  .col-sm-1,
  .col-sm-2,
  .col-sm-3,
  .col-sm-4,
  .col-sm-5,
  .col-sm-6,
  .col-sm-7,
  .col-sm-8,
  .col-sm-9,
  .col-sm-10,
  .col-sm-11,
  .col-sm-12,
  .col-sm-offset-0,
  .col-sm-offset-1,
  .col-sm-offset-2,
  .col-sm-offset-3,
  .col-sm-offset-4,
  .col-sm-offset-5,
  .col-sm-offset-6,
  .col-sm-offset-7,
  .col-sm-offset-8,
  .col-sm-offset-9,
  .col-sm-offset-10,
  .col-sm-offset-11,
  .col-sm-offset-12 {
    box-sizing: border-box;
    -webkit-box-flex: 0;
    -ms-flex: 0 0 auto;
    flex: 0 0 auto;
    padding-right: 0.5rem;
    padding-left: 0.5rem;
  }

  .col-sm {
    -webkit-box-flex: 1;
    -ms-flex-positive: 1;
    flex-grow: 1;
    -ms-flex-preferred-size: 0;
    flex-basis: 0;
    max-width: 100%;
  }

  .col-sm-1 {
    -ms-flex-preferred-size: 8.33333333%;
    flex-basis: 8.33333333%;
    max-width: 8.33333333%;
  }

  .col-sm-2 {
    -ms-flex-preferred-size: 16.66666667%;
    flex-basis: 16.66666667%;
    max-width: 16.66666667%;
  }

  .col-sm-3 {
    -ms-flex-preferred-size: 25%;
    flex-basis: 25%;
    max-width: 25%;
  }

  .col-sm-4 {
    -ms-flex-preferred-size: 33.33333333%;
    flex-basis: 33.33333333%;
    max-width: 33.33333333%;
  }

  .col-sm-5 {
    -ms-flex-preferred-size: 41.66666667%;
    flex-basis: 41.66666667%;
    max-width: 41.66666667%;
  }

  .col-sm-6 {
    -ms-flex-preferred-size: 50%;
    flex-basis: 50%;
    max-width: 50%;
  }

  .col-sm-7 {
    -ms-flex-preferred-size: 58.33333333%;
    flex-basis: 58.33333333%;
    max-width: 58.33333333%;
  }

  .col-sm-8 {
    -ms-flex-preferred-size: 66.66666667%;
    flex-basis: 66.66666667%;
    max-width: 66.66666667%;
  }

  .col-sm-9 {
    -ms-flex-preferred-size: 75%;
    flex-basis: 75%;
    max-width: 75%;
  }

  .col-sm-10 {
    -ms-flex-preferred-size: 83.33333333%;
    flex-basis: 83.33333333%;
    max-width: 83.33333333%;
  }

  .col-sm-11 {
    -ms-flex-preferred-size: 91.66666667%;
    flex-basis: 91.66666667%;
    max-width: 91.66666667%;
  }

  .col-sm-12 {
    -ms-flex-preferred-size: 100%;
    flex-basis: 100%;
    max-width: 100%;
  }

  .col-sm-offset-0 {
    margin-left: 0;
  }

  .col-sm-offset-1 {
    margin-left: 8.33333333%;
  }

  .col-sm-offset-2 {
    margin-left: 16.66666667%;
  }

  .col-sm-offset-3 {
    margin-left: 25%;
  }

  .col-sm-offset-4 {
    margin-left: 33.33333333%;
  }

  .col-sm-offset-5 {
    margin-left: 41.66666667%;
  }

  .col-sm-offset-6 {
    margin-left: 50%;
  }

  .col-sm-offset-7 {
    margin-left: 58.33333333%;
  }

  .col-sm-offset-8 {
    margin-left: 66.66666667%;
  }

  .col-sm-offset-9 {
    margin-left: 75%;
  }

  .col-sm-offset-10 {
    margin-left: 83.33333333%;
  }

  .col-sm-offset-11 {
    margin-left: 91.66666667%;
  }

  .start-sm {
    -webkit-box-pack: start;
    -ms-flex-pack: start;
    justify-content: flex-start;
    text-align: start;
  }

  .center-sm {
    -webkit-box-pack: center;
    -ms-flex-pack: center;
    justify-content: center;
    text-align: center;
  }

  .end-sm {
    -webkit-box-pack: end;
    -ms-flex-pack: end;
    justify-content: flex-end;
    text-align: end;
  }

  .top-sm {
    -webkit-box-align: start;
    -ms-flex-align: start;
    align-items: flex-start;
  }

  .middle-sm {
    -webkit-box-align: center;
    -ms-flex-align: center;
    align-items: center;
  }

  .bottom-sm {
    -webkit-box-align: end;
    -ms-flex-align: end;
    align-items: flex-end;
  }

  .around-sm {
    -ms-flex-pack: distribute;
    justify-content: space-around;
  }

  .between-sm {
    -webkit-box-pack: justify;
    -ms-flex-pack: justify;
    justify-content: space-between;
  }

  .first-sm {
    -webkit-box-ordinal-group: 0;
    -ms-flex-order: -1;
    order: -1;
  }

  .last-sm {
    -webkit-box-ordinal-group: 2;
    -ms-flex-order: 1;
    order: 1;
  }
}

@media only screen and (min-width: 64em) {
  .container {
    width: 65rem;
  }

  .col-md,
  .col-md-1,
  .col-md-2,
  .col-md-3,
  .col-md-4,
  .col-md-5,
  .col-md-6,
  .col-md-7,
  .col-md-8,
  .col-md-9,
  .col-md-10,
  .col-md-11,
  .col-md-12,
  .col-md-offset-0,
  .col-md-offset-1,
  .col-md-offset-2,
  .col-md-offset-3,
  .col-md-offset-4,
  .col-md-offset-5,
  .col-md-offset-6,
  .col-md-offset-7,
  .col-md-offset-8,
  .col-md-offset-9,
  .col-md-offset-10,
  .col-md-offset-11,
  .col-md-offset-12 {
    box-sizing: border-box;
    -webkit-box-flex: 0;
    -ms-flex: 0 0 auto;
    flex: 0 0 auto;
    padding-right: 0.5rem;
    padding-left: 0.5rem;
  }

  .col-md {
    -webkit-box-flex: 1;
    -ms-flex-positive: 1;
    flex-grow: 1;
    -ms-flex-preferred-size: 0;
    flex-basis: 0;
    max-width: 100%;
  }

  .col-md-1 {
    -ms-flex-preferred-size: 8.33333333%;
    flex-basis: 8.33333333%;
    max-width: 8.33333333%;
  }

  .col-md-2 {
    -ms-flex-preferred-size: 16.66666667%;
    flex-basis: 16.66666667%;
    max-width: 16.66666667%;
  }

  .col-md-3 {
    -ms-flex-preferred-size: 25%;
    flex-basis: 25%;
    max-width: 25%;
  }

  .col-md-4 {
    -ms-flex-preferred-size: 33.33333333%;
    flex-basis: 33.33333333%;
    max-width: 33.33333333%;
  }

  .col-md-5 {
    -ms-flex-preferred-size: 41.66666667%;
    flex-basis: 41.66666667%;
    max-width: 41.66666667%;
  }

  .col-md-6 {
    -ms-flex-preferred-size: 50%;
    flex-basis: 50%;
    max-width: 50%;
  }

  .col-md-7 {
    -ms-flex-preferred-size: 58.33333333%;
    flex-basis: 58.33333333%;
    max-width: 58.33333333%;
  }

  .col-md-8 {
    -ms-flex-preferred-size: 66.66666667%;
    flex-basis: 66.66666667%;
    max-width: 66.66666667%;
  }

  .col-md-9 {
    -ms-flex-preferred-size: 75%;
    flex-basis: 75%;
    max-width: 75%;
  }

  .col-md-10 {
    -ms-flex-preferred-size: 83.33333333%;
    flex-basis: 83.33333333%;
    max-width: 83.33333333%;
  }

  .col-md-11 {
    -ms-flex-preferred-size: 91.66666667%;
    flex-basis: 91.66666667%;
    max-width: 91.66666667%;
  }

  .col-md-12 {
    -ms-flex-preferred-size: 100%;
    flex-basis: 100%;
    max-width: 100%;
  }

  .col-md-offset-0 {
    margin-left: 0;
  }

  .col-md-offset-1 {
    margin-left: 8.33333333%;
  }

  .col-md-offset-2 {
    margin-left: 16.66666667%;
  }

  .col-md-offset-3 {
    margin-left: 25%;
  }

  .col-md-offset-4 {
    margin-left: 33.33333333%;
  }

  .col-md-offset-5 {
    margin-left: 41.66666667%;
  }

  .col-md-offset-6 {
    margin-left: 50%;
  }

  .col-md-offset-7 {
    margin-left: 58.33333333%;
  }

  .col-md-offset-8 {
    margin-left: 66.66666667%;
  }

  .col-md-offset-9 {
    margin-left: 75%;
  }

  .col-md-offset-10 {
    margin-left: 83.33333333%;
  }

  .col-md-offset-11 {
    margin-left: 91.66666667%;
  }

  .start-md {
    -webkit-box-pack: start;
    -ms-flex-pack: start;
    justify-content: flex-start;
    text-align: start;
  }

  .center-md {
    -webkit-box-pack: center;
    -ms-flex-pack: center;
    justify-content: center;
    text-align: center;
  }

  .end-md {
    -webkit-box-pack: end;
    -ms-flex-pack: end;
    justify-content: flex-end;
    text-align: end;
  }

  .top-md {
    -webkit-box-align: start;
    -ms-flex-align: start;
    align-items: flex-start;
  }

  .middle-md {
    -webkit-box-align: center;
    -ms-flex-align: center;
    align-items: center;
  }

  .bottom-md {
    -webkit-box-align: end;
    -ms-flex-align: end;
    align-items: flex-end;
  }

  .around-md {
    -ms-flex-pack: distribute;
    justify-content: space-around;
  }

  .between-md {
    -webkit-box-pack: justify;
    -ms-flex-pack: justify;
    justify-content: space-between;
  }

  .first-md {
    -webkit-box-ordinal-group: 0;
    -ms-flex-order: -1;
    order: -1;
  }

  .last-md {
    -webkit-box-ordinal-group: 2;
    -ms-flex-order: 1;
    order: 1;
  }
}

@media only screen and (min-width: 75em) {
  .container {
    width: 76rem;
  }

  .col-lg,
  .col-lg-1,
  .col-lg-2,
  .col-lg-3,
  .col-lg-4,
  .col-lg-5,
  .col-lg-6,
  .col-lg-7,
  .col-lg-8,
  .col-lg-9,
  .col-lg-10,
  .col-lg-11,
  .col-lg-12,
  .col-lg-offset-0,
  .col-lg-offset-1,
  .col-lg-offset-2,
  .col-lg-offset-3,
  .col-lg-offset-4,
  .col-lg-offset-5,
  .col-lg-offset-6,
  .col-lg-offset-7,
  .col-lg-offset-8,
  .col-lg-offset-9,
  .col-lg-offset-10,
  .col-lg-offset-11,
  .col-lg-offset-12 {
    box-sizing: border-box;
    -webkit-box-flex: 0;
    -ms-flex: 0 0 auto;
    flex: 0 0 auto;
    padding-right: 0.5rem;
    padding-left: 0.5rem;
  }

  .col-lg {
    -webkit-box-flex: 1;
    -ms-flex-positive: 1;
    flex-grow: 1;
    -ms-flex-preferred-size: 0;
    flex-basis: 0;
    max-width: 100%;
  }

  .col-lg-1 {
    -ms-flex-preferred-size: 8.33333333%;
    flex-basis: 8.33333333%;
    max-width: 8.33333333%;
  }

  .col-lg-2 {
    -ms-flex-preferred-size: 16.66666667%;
    flex-basis: 16.66666667%;
    max-width: 16.66666667%;
  }

  .col-lg-3 {
    -ms-flex-preferred-size: 25%;
    flex-basis: 25%;
    max-width: 25%;
  }

  .col-lg-4 {
    -ms-flex-preferred-size: 33.33333333%;
    flex-basis: 33.33333333%;
    max-width: 33.33333333%;
  }

  .col-lg-5 {
    -ms-flex-preferred-size: 41.66666667%;
    flex-basis: 41.66666667%;
    max-width: 41.66666667%;
  }

  .col-lg-6 {
    -ms-flex-preferred-size: 50%;
    flex-basis: 50%;
    max-width: 50%;
  }

  .col-lg-7 {
    -ms-flex-preferred-size: 58.33333333%;
    flex-basis: 58.33333333%;
    max-width: 58.33333333%;
  }

  .col-lg-8 {
    -ms-flex-preferred-size: 66.66666667%;
    flex-basis: 66.66666667%;
    max-width: 66.66666667%;
  }

  .col-lg-9 {
    -ms-flex-preferred-size: 75%;
    flex-basis: 75%;
    max-width: 75%;
  }

  .col-lg-10 {
    -ms-flex-preferred-size: 83.33333333%;
    flex-basis: 83.33333333%;
    max-width: 83.33333333%;
  }

  .col-lg-11 {
    -ms-flex-preferred-size: 91.66666667%;
    flex-basis: 91.66666667%;
    max-width: 91.66666667%;
  }

  .col-lg-12 {
    -ms-flex-preferred-size: 100%;
    flex-basis: 100%;
    max-width: 100%;
  }

  .col-lg-offset-0 {
    margin-left: 0;
  }

  .col-lg-offset-1 {
    margin-left: 8.33333333%;
  }

  .col-lg-offset-2 {
    margin-left: 16.66666667%;
  }

  .col-lg-offset-3 {
    margin-left: 25%;
  }

  .col-lg-offset-4 {
    margin-left: 33.33333333%;
  }

  .col-lg-offset-5 {
    margin-left: 41.66666667%;
  }

  .col-lg-offset-6 {
    margin-left: 50%;
  }

  .col-lg-offset-7 {
    margin-left: 58.33333333%;
  }

  .col-lg-offset-8 {
    margin-left: 66.66666667%;
  }

  .col-lg-offset-9 {
    margin-left: 75%;
  }

  .col-lg-offset-10 {
    margin-left: 83.33333333%;
  }

  .col-lg-offset-11 {
    margin-left: 91.66666667%;
  }

  .start-lg {
    -webkit-box-pack: start;
    -ms-flex-pack: start;
    justify-content: flex-start;
    text-align: start;
  }

  .center-lg {
    -webkit-box-pack: center;
    -ms-flex-pack: center;
    justify-content: center;
    text-align: center;
  }

  .end-lg {
    -webkit-box-pack: end;
    -ms-flex-pack: end;
    justify-content: flex-end;
    text-align: end;
  }

  .top-lg {
    -webkit-box-align: start;
    -ms-flex-align: start;
    align-items: flex-start;
  }

  .middle-lg {
    -webkit-box-align: center;
    -ms-flex-align: center;
    align-items: center;
  }

  .bottom-lg {
    -webkit-box-align: end;
    -ms-flex-align: end;
    align-items: flex-end;
  }

  .around-lg {
    -ms-flex-pack: distribute;
    justify-content: space-around;
  }

  .between-lg {
    -webkit-box-pack: justify;
    -ms-flex-pack: justify;
    justify-content: space-between;
  }

  .first-lg {
    -webkit-box-ordinal-group: 0;
    -ms-flex-order: -1;
    order: -1;
  }

  .last-lg {
    -webkit-box-ordinal-group: 2;
    -ms-flex-order: 1;
    order: 1;
  }
}
</style>
