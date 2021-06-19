<template>
  <div>
    <h2>Recent Race Stats</h2>
    <div v-if="lastRace" class="">
      <h3> TEMP NAME</h3>
      <div v-for="(racer,index) in lastRace" :key="index" class="">
        <h4 v-html="racer.position" />
        <h4 v-html="racer.player_name" />
        <h4 v-html="racer.best_lap" />
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'home-screen',
  props: {
    
  },
  data() {
    return {
      lastRace : this.$store.state.home.lastRace
    }
  },
  methods: {
    getLastRace: function() {

    }
  },
  mounted() {
      this.listener = window.addEventListener(
      'message',
      event => {
        const item = event.data || event.detail;
        if (item.raceData) {
          console.log(item);
          console.log("race data");
          this.$store.state.home.lastRace = item.message;
        }
      },
      false,
    );
  },
};
</script>

<style scoped></style>
