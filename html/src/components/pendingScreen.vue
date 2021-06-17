<template>
  <div>
    <h3>Build pending template</h3>
    <div v-if="!joinedRace">
      <div v-for="(track,index) in pendingObject" :key="index">
          <div class="grid third center">
            <div><h4 v-html="trackObject[track.race_id - 1].Config.Name"/></div>
            <div><button @click="joinRace(track.race_id)" class="">Join Race</button></div>
            <div><button @click="mapRace(track.race_id)" class="">Map To Race</button></div>
          </div>
      </div>
    </div>
    <div v-else >
      <div>
        <button @click="getPlayersInRace">Refresh Racers List</button>
        <h3>Active Race: <span v-html="trackObject[race_id - 1].Config.Name"/> </h3>
      </div>
    </div>
  </div>
</template>

<script>
import Nui from '../utils/Nui';
export default {
  name: 'pending-screen',
  props: {
    pendingList: []
  },
  data() {
    return {
      trackObject :  this.$store.state.trackList,
      pendingObject: this.pendingList,
      joinedRace: this.$store.state.raceApp.joinedRace,
      race_id: this.$store.state.raceApp.race_id
    };
  },
  methods: {
    mapRace: function(raceId) {
        Nui.send('mapToRace',{raceId})
    },
    joinRace: function(raceId) {
        Nui.send('joinRace',{raceId})
        this.joinedRace = true;
        this.race_id = raceId;
    },
    getPlayersInRace: function() {
      return "null";
    }
  },
  mounted() {
    this.listener = window.addEventListener(
      'message',
      event => {
        const item = event.data || event.detail;
        if (item.joinError) {
          this.joinedRace = false,
          this.race_id = 0
        }
      },
      false,
    );
  }
};
</script>

<style lang="scss">
</style>
