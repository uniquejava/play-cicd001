<script setup lang="ts">
import TicketList from './components/TicketList.vue'
</script>

<template>
  <div id="app">
    <header class="app-header">
      <h1>🎫 Ticket Management System</h1>
      <p>A simple CI/CD demonstration project</p>
      <small style="color: #999; font-size: 12px;">v1.0.4 - Full CI/CD Flow Test 🚀</small>
    </header>

    <main class="app-main">
      <TicketList />
    </main>
  </div>
</template>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',
    'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue',
    sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  background-color: #f5f5f5;
}

#app {
  min-height: 100vh;
}

.app-header {
  background-color: #fff;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  padding: 20px;
  text-align: center;
  border-bottom: 1px solid #e0e0e0;
}

.app-header h1 {
  color: #333;
  margin-bottom: 8px;
  font-size: 28px;
}

.app-header p {
  color: #666;
  font-size: 14px;
}

.app-main {
  flex: 1;
  padding: 0;
}
</style>
