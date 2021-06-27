<template>
  <div>
    <div v-if="!joinedRace && !isOwner">
      <div v-for="(track,index) in pendingObject" :key="index">
          <div class="center row" :class="{evenRow: index % 2 == 0}">
            <div class="col-md-6 ut-vertAlignCenter"><h4 v-html="track.name + ' Laps:'+ track.laps"/></div>
            <div class="col-md-3 ut-vertAlignCenter"><button @click="joinRace(track.id)" class="">Join Race</button></div>
            <div class="col-md-3 ut-vertAlignCenter"><button @click="mapRace(track.id)" class="">Map To Race</button></div>
          </div>
      </div>
    </div>
    <div v-else >
      <div>
        <button @click="getPlayersInRace">Refresh Racers List</button>
        <h3>Active Race: <span v-html="trackObject[raceId - 1].Config.Name"/> </h3>
        <div class="row">
          <div class="col-md-4 ut-vertAlignCenter" v-if="isOwner">
            <button @click="startRace(raceId)" class="">Start Race</button>
          </div>
          <div class="col-md-4 ut-vertAlignCenter">
            <button @click="mapRace(raceId)" class="">Map To Race</button>
          </div>
          <div class="col-md-4 ut-vertAlignCenter" v-if="isOwner">
            <button @click="quitRace()" class="">Cancel Race</button>
          </div>
          <div class="col-md-4 ut-vertAlignCenter" v-else>
            <button @click="quitRace()" class="">Quit Race</button>
          </div>
        </div>
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
      participatingRace: {},
    };
  },
  methods: {
    mapRace: function(raceId) {
        Nui.send('mapToRace',{raceId})
    },
    startRace: function(raceId) {
        Nui.send('startRace',{raceId})
    },
    joinRace: function(raceId) {
        Nui.send('joinRace',{raceId})
        this.$store.state.raceApp.joinedRace = true;
        this.$store.state.raceApp.race_id = raceId;
    },
    quitRace: function() {
        Nui.send('quitRace',{})
        this.$store.state.raceApp.joinedRace = false;
        this.$store.state.raceApp.race_id = 0;
        this.$store.state.raceApp.isOwner = false;
        Nui.send('getPendingRaces',{})
    },
    getPlayersInRace: function() {
        // Nui.send('raceDetails',{raceId})
      return "null";
    },
    getParticipatingRace: function() {
      for(var x = 0; x < this.pendingObject.length; x++) {
        if(this.pendingObject[x].race_id == this.race_id) {
          this.participatingRace = x;
          return x;
        }
      }
      return false;
    },
    checkIfOwner: function() {
      if(this.pendingObject.length > 0 && !this.isOwner) {
        for (var x =0; x < this.pendingObject.length; x++)
        {
          if(this.identity.includes(this.pendingObject[x].owner)) {
            this.$store.state.raceApp.race_id = this.pendingObject[x].id;
            this.$store.state.raceApp.isOwner = true;
            this.$store.state.raceApp.joinedRace = true;
          }
        }
      }
    }
  },
  mounted() {
    this.listener = window.addEventListener(
      'message',
      event => {
        const item = event.data || event.detail;
        if (item.joinError) {
          this.$store.state.raceApp.joinedRace = false,
          this.race_id = 0
        }
        if (item.racingListEvent) {
            // this.checkIfOwner();
        }
      },
      false,
    );
  },
  computed: {
    pendingObject: function() {
      return this.$store.state.pendingList;
    },
    identity: function() {
      return this.$store.state.global.identifier;
    },
    trackObject: function() {
      return this.$store.state.trackList;
    },
    isOwner: function() {
      return this.$store.state.raceApp.isOwner;
    },
    joinedRace: function() {
      return this.$store.state.raceApp.joinedRace;
    },
    raceId: function() {
      return this.$store.state.raceApp.race_id;
    }
  }
};
</script>

<style lang="scss">
</style>
