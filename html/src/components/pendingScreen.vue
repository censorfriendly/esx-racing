<template>
  <div>
    <div v-if="!joinedRace && !isOwner">
      <div v-for="(track,index) in pendingObject" :key="index">
          <div class="center row" :class="{evenRow: index % 2 == 0}">
            <div class="col-md-12 ut-vertAlignCenter"><h4 v-html="track.title"/></div>
            <div class="col-md-4 ut-vertAlignCenter"><h4 v-html="track.name + ' Laps:'+ track.laps"/></div>
            <div class="col-md-4 ut-vertAlignCenter"><button @click="joinRace(track.id)" class="">Join Race</button></div>
            <div class="col-md-4 ut-vertAlignCenter"><button @click="mapRace(track.id)" class="">Map To Race</button></div>
          </div>
      </div>
    </div>
    <div v-else-if="getParticipatingRace" >
      <div>
        <button @click="getPlayersInRace">Refresh Racers List</button>
        <h3 v-html="getParticipatingRace.title"/>
        <h3>Track: <span v-html="getParticipatingRace.name"/> Laps: <span v-html="getParticipatingRace.laps"/></h3>
        <div class="row mb-2">
          <div class="col-md-3 ut-vertAlignCenter" v-if="isOwner">
            <button @click="startRace(raceId)" class="">Start Race</button>
          </div>
          <div class="col-md-3 ut-vertAlignCenter">
            <button @click="mapRace(raceId)" class="">Map To Race</button>
          </div>
          <div class="col-md-3 ut-vertAlignCenter" v-if="isOwner">
            <button @click="quitRace()" class="">Cancel Race</button>
          </div>
          <div class="col-md-3 ut-vertAlignCenter" v-else>
            <button @click="quitRace()" class="">Quit Race</button>
          </div>
          <div class="col-md-3 ut-vertAlignCenter" v-if="isOwner">
            <button @click="formActive = true" class="">Message Racers</button>
          </div>
        </div>
        <div v-for="(racer,index) in racersList" :key="index">
          <div class="center row" :class="{evenRow: index % 2 == 0}">
            <div class="col-md-12"><h4 v-html="racer.player_name"/></div>
          </div>
        </div>
      </div>
    </div>
    <div class="formSlideDown col-md-12" :class="{active:formActive}">
      <div class="p-2">
          <strong class="col-md-6">Message*</strong>
          <input width="300px" height="90px" type="text" class="col-md-offset-1 col-md-5" v-model="message" />
          <input type="hidden" :value="raceId"/>
          <div class="row ut-vertAlignCenter mt center">
            <div class="col-md-6">
              <button @click="sendMessage" class="btn">Send Message</button>
            </div>
            <div class="col-md-6">
              <button @click="formActive = false" class="btn">Cancel Message</button>
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
      racerList: [],
      message:"",
      formActive: false
    };
  },
  methods: {
    mapRace: function(raceId) {
        Nui.send('mapToRace',{raceId})
    },
    startRace: function(raceId) {
        Nui.send('startRace',{raceId})
    },
    sendMessage: function() {
      if(this.message !== "") {
            Nui.send('sendMessage',{
              raceId: this.raceId,
              message: this.$sanitize(this.message)
            })
        this.message = "";
        this.formActive = false;
      }
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
        Nui.send('raceDetails',{raceId:this.raceId})
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
    },
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
        if (item.raceInfo) {
          this.racerList = item.info;
          
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
    },
    racersList: function() {
      return this.racerList;
    },
    getParticipatingRace: function() {
      if(this.$store.state.pendingList) {
        return this.$store.state.pendingList.filter((r) => {if(r.id === this.raceId) {return r}})[0];
      }
      return {}
    }
  }
};
</script>

<style lang="scss">
</style>
