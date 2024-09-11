<script>
import { Head } from '@inertiajs/vue2';
import YourWorkProjectsApp from '~/projects/your_work/components/app.vue';

export default {
  components: {
    Head,
    YourWorkProjectsApp,
  },
  props: {},
};
</script>

<template>
  <div>
    <Head title="Projects" />
    <your-work-projects-app />
  </div>
</template>
