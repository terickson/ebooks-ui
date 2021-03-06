import Vue from 'vue'
import App from './App.vue'
import BootstrapVue from 'bootstrap-vue'
import ReadMore from 'vue-read-more';

Vue.use(ReadMore);
Vue.use(require('vue-moment'));
Vue.use(BootstrapVue);

new Vue({
  el: '#app',
  render: h => h(App)
})
