import Vue from 'vue';
import App from './App.vue';
import Nui from './utils/Nui';
import store from './utils/store'
import VueDragscroll from 'vue-dragscroll'
import VueSanitize from "vue-sanitize";

Vue.config.productionTip = false;
Vue.use(VueDragscroll)

var defaultOptions = {
  allowedTags: [],
  allowedAttributes: {
  }
};
Vue.use(VueSanitize, defaultOptions);

new Vue({
  store,
  render: h => h(App),
}).$mount('#app');

/// #if DEBUG
setTimeout(() => {
  Nui.emulate('some method', {
    arg: '🐌',
  });
}, 100);

document.addEventListener('keypress', event => {
  if (event.keyCode == 116) {
    // do something
  }
});
/// #endif
