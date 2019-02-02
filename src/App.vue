<template>
  <div id="app" class="container-fluid">
    <div>
      <div class="row">
        <div class="col align-self-start">
          <b-btn v-b-toggle.filters variant="primary">Filters</b-btn>
        </div>
        <div class="col align-self-end text-right">
          <select  v-model="sort" v-on:change="offset = 0; getBooks();">
            <option value="title,rating">Sort by Title asc</option>
            <option value="-title,rating">Sort by Title desc</option>
            <option value="rating,title">Sort By Rating asc</option>
            <option value="-rating,title">Sort By Rating desc</option>
            <option value="series,series_index,-rating,title">Sort By Series asc</option>
            <option value="series,-series_index,-rating,title">Sort By Series desc</option>
          </select>
        </div>
    </div>

      <b-collapse id="filters" class="mt-2">
        <b-card>
          <div class="row">
            <div class="col">
              <input v-model="title" v-on:blur="offset = 0; getBooks();" type="text" placeholder="Title Contains">
            </div>
          <div class="col">
            <input v-model="series" v-on:blur="offset = 0; getBooks();" type="text" placeholder="Series Contains">
          </div>
          <div class="col">
            <input v-model="subject" v-on:blur="offset = 0; getBooks();" type="text" placeholder="Subject Contains">
          </div>
          <div class="col">
            <input v-model="author" v-on:blur="offset = 0; getBooks();" type="text" placeholder="Author Contains">
          </div>
          <div class="col">
            <select v-model="rating" v-on:change="offset = 0; getBooks();">
              <option value="">No Minimum Rating</option>
              <option value="1">Rating must be at least 1</option>
              <option value="2">Rating must be at least 2</option>
              <option value="3">Rating must be at least 3</option>
              <option value="4">Rating must be at least 4</option>
            </select>
          </div>
        </div>
        </b-card>
      </b-collapse>
    </div>

    <div class="row mt-2">
      <div class="col align-self-start">
        <button class="btn btn-primary" v-bind:class="{ disabled: (offset === 0) }" v-on:click="previous()">Previous</button>
      </div>
      <div class="col align-self-end text-right">
        <button class="btn btn-primary" v-on:click="next();">Next</button>
      </div>
    </div>

    <div class="card mt-2" v-for="book of books">
      <!--<img class="card-img-top" src="..." alt="Card image cap">-->
      <div class="card-body">
        <div class="row">
          <div class="col align-self-start">
            <h5 class="card-title">
              {{book.title}}
            </h5>
          </div>
          <div class="col-1 align-self-end text-right">
            <a class="btn btn-primary btn-sm" :href="'http://localhost:8082/books/' + book.id + '/download'">download</a>
          </div>
        </div>
        <h6 class="card-authors">
          <div class="row">
            <div class="col-md-2" v-for="ab of book.AuthorBooks">
              {{ab.Author.name}}
            </div>
          </div>
        </h6>
        <h6 class="card-series" v-if="book.series">{{book.series}}: {{book.series_index}}</h6>
        <h6 class="card-rating" v-if="book.rating">
          <div class="row">
            <div class="col-md-2">
              Rating: {{book.rating}}
            </div>
            <div class="col-md-2">
              Page Count: {{book.pages}}
            </div>
            <div class="col-md-2">
              Language: {{book.language}}
            </div>
          </div>
        </h6>
        <read-more more-str="read more" :text="(book.description)?book.description:''" link="#" less-str="read less" :max-chars="250"></read-more>
        <h6 class="card-pagecount" v-if="book.pages"></h6>
        <h6 class="card-extrainfo">
          <div class="row">
           <div class="col-md-2">
              Publisher: {{book.publisher}}
          </div>
          <div class="col-md-2">
            Date: {{book.publication_date | moment("MMM Do YYYY")}}
          </div>
        </div>
        </h6>
        <a :href="'https://www.goodreads.com/book/show/' + book.grid" class="btn btn-primary" v-if="book.grid">View on GoodReads</a>
      </div>
    </div>

  </div>
</template>

<script>
import Autocomplete from 'vue2-autocomplete-js';
import axios from 'axios';
const config = { headers: {'Content-Type': 'application/json','Cache-Control' : 'no-cache'}};

export default {
  name: 'app',
  data() {
    return {
      books: [],
      errors: [],
      sort: "title,rating",
      title: null,
      series: null,
      subject: null,
      author: null,
      rating: "",
      limit: 1000,
      offset: 0
    }
  },
  methods: {
    previous(){
      if(this.offset === 0){
        return;
      }
      this.offset -= this.limit;
      this.getBooks();
    },
    next(){
      this.offset += this.limit;
      this.getBooks();
    },
    getBooks() {
      let filters = "";
      if(this.title){
        filters += "&title={%22$ilike%22:%22%25" + this.title + "%25%22}"
      }
      if(this.series){
        filters += "&series={%22$ilike%22:%22%25" + this.series + "%25%22}"
      }
      if(this.subject){
        filters += "&Subjects.subject={%22$ilike%22:%22%25" + this.subject + "%25%22}"
      }
      if(this.author){
        filters += "&AuthorBooks.Author.name={%22$ilike%22:%22%25" + this.author + "%25%22}"
      }
      if(this.rating){
        filters += "&rating={%22$gte%22:" + this.rating + "}"
      }
      if(this.author || this.subject){
        filters += "&requireIncludes=true"
      }
      axios.get("http://localhost:8082/books?includes=AuthorBooks.Author,Subjects&sort=" + this.sort + "&limit=" + this.limit + "&offset=" + this.offset + filters, config)
      .then(response => {
        this.books = response.data
      })
      .catch(e => {
        this.errors.push(e)
      })
    }
  },
  components: {
      Autocomplete
  },
  created() {
    this.getBooks();
  }
}
</script>

<style lang="scss">
@import './styles/custom-bootstrap.scss';
@import '../node_modules/bootstrap/dist/css/bootstrap.css';
@import '../node_modules/bootstrap-vue/dist/bootstrap-vue.css';
@import '../node_modules/vue2-autocomplete-js/dist/style/vue2-autocomplete.css'
</style>
