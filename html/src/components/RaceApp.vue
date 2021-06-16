<template>
  <div class="racing-app">
        <h1>Race App Screen</h1>
        <hr/>
        <div class="grid third center">
            <div class="tab" :class="{active:index==1}" @click="index = 1">Pending Races</div>
            <div class="tab" :class="{active:index==2}" @click="index = 2">Tracks</div>
            <div class="tab" :class="{active:index==3}" @click="index = 3">Leaderboards</div>
        </div>
        <div class="interior-page">
            <div v-if="index==1">
                <pendingScreen />
            </div>
            <div v-else-if="index==2">
                <trackScreen />
            </div>
            <div v-else-if="index==3">
                <leaderboardScreen />
            </div>
        </div>
  </div>
</template>

<script>
import pendingScreen from './pendingScreen';
import leaderboardScreen from './leaderboardScreen';
import trackScreen from './trackScreen';
export default {
  name: 'race-app',
  components: {
      pendingScreen,
      leaderboardScreen,
      trackScreen,
  },
  props: {
  },
  data() {
    return {
      index : 1
    };
  },

};
</script>

<style lang="scss">
.racing-app {
    display: none;
    background-color: green;
    position: absolute;
    bottom:0px;
    right:0px;
    padding:15px;
    min-height: 25%;
    min-width: 400px;
    .interior-page {
        height: 500px;
        overflow-y:auto;
    }
}
.tab {
    cursor: pointer;
    &.active {
        background-color: black;
        color: white;
    }
}
</style>
