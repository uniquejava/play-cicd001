<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { ticketService } from '@/services/ticketService'
import type { Ticket } from '@/types/ticket'
import TicketForm from './TicketForm.vue'

const tickets = ref<Ticket[]>([])
const loading = ref(false)
const error = ref('')
const showForm = ref(false)
const editingTicket = ref<Ticket | null>(null)

const fetchTickets = async () => {
  loading.value = true
  error.value = ''
  try {
    tickets.value = await ticketService.getAllTickets()
  } catch (err) {
    error.value = err instanceof Error ? err.message : 'Failed to fetch tickets'
  } finally {
    loading.value = false
  }
}

const handleCreateTicket = () => {
  editingTicket.value = null
  showForm.value = true
}

const handleEditTicket = (ticket: Ticket) => {
  editingTicket.value = ticket
  showForm.value = true
}

const handleDeleteTicket = async (id: number) => {
  if (!confirm('Are you sure you want to delete this ticket?')) {
    return
  }

  try {
    await ticketService.deleteTicket(id)
    await fetchTickets()
  } catch (err) {
    error.value = err instanceof Error ? err.message : 'Failed to delete ticket'
  }
}

const handleUpdateStatus = async (id: number, status: string) => {
  try {
    await ticketService.updateTicketStatus(id, status)
    await fetchTickets()
  } catch (err) {
    error.value = err instanceof Error ? err.message : 'Failed to update ticket status'
  }
}

const handleFormSubmit = async () => {
  showForm.value = false
  editingTicket.value = null
  await fetchTickets()
}

const getStatusColor = (status: string) => {
  switch (status) {
    case 'OPEN':
      return 'bg-blue-100 text-blue-800'
    case 'IN_PROGRESS':
      return 'bg-yellow-100 text-yellow-800'
    case 'CLOSED':
      return 'bg-green-100 text-green-800'
    default:
      return 'bg-gray-100 text-gray-800'
  }
}

onMounted(() => {
  fetchTickets()
})
</script>

<template>
  <div class="ticket-list">
    <div class="header">
      <h2> tickets</h2>
      <button @click="handleCreateTicket" class="btn btn-primary">
        Create Ticket
      </button>
    </div>

    <div v-if="error" class="error">
      {{ error }}
    </div>

    <div v-if="loading" class="loading">
      Loading tickets...
    </div>

    <div v-else-if="tickets.length === 0" class="empty">
      No tickets found. Create your first ticket!
    </div>

    <div v-else class="tickets-grid">
      <div v-for="ticket in tickets" :key="ticket.id" class="ticket-card">
        <div class="ticket-header">
          <h3>{{ ticket.title }}</h3>
          <span :class="['status-badge', getStatusColor(ticket.status)]">
            {{ ticket.status.replace('_', ' ') }}
          </span>
        </div>

        <p class="ticket-description">
          {{ ticket.description || 'No description' }}
        </p>

        <div class="ticket-meta">
          <small>Created: {{ new Date(ticket.createdAt).toLocaleDateString() }}</small>
          <small>Updated: {{ new Date(ticket.updatedAt).toLocaleDateString() }}</small>
        </div>

        <div class="ticket-actions">
          <select
            :value="ticket.status"
            @change="handleUpdateStatus(ticket.id, ($event.target as HTMLSelectElement).value)"
            class="status-select"
          >
            <option value="OPEN">Open</option>
            <option value="IN_PROGRESS">In Progress</option>
            <option value="CLOSED">Closed</option>
          </select>

          <button @click="handleEditTicket(ticket)" class="btn btn-secondary">
            Edit
          </button>

          <button @click="handleDeleteTicket(ticket.id)" class="btn btn-danger">
            Delete
          </button>
        </div>
      </div>
    </div>

    <!-- Ticket Form Modal -->
    <div v-if="showForm" class="modal-overlay" @click.self="showForm = false">
      <div class="modal-content">
        <TicketForm
          :ticket="editingTicket"
          @submit="handleFormSubmit"
          @cancel="showForm = false"
        />
      </div>
    </div>
  </div>
</template>

<style scoped>
.ticket-list {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.header h2 {
  margin: 0;
  color: #333;
}

.btn {
  padding: 8px 16px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
  transition: background-color 0.2s;
}

.btn-primary {
  background-color: #007bff;
  color: white;
}

.btn-primary:hover {
  background-color: #0056b3;
}

.btn-secondary {
  background-color: #6c757d;
  color: white;
  margin-right: 8px;
}

.btn-secondary:hover {
  background-color: #545b62;
}

.btn-danger {
  background-color: #dc3545;
  color: white;
}

.btn-danger:hover {
  background-color: #c82333;
}

.error {
  background-color: #f8d7da;
  color: #721c24;
  padding: 12px;
  border-radius: 4px;
  margin-bottom: 20px;
}

.loading, .empty {
  text-align: center;
  padding: 40px;
  color: #666;
}

.tickets-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
  gap: 20px;
}

.ticket-card {
  background: white;
  border: 1px solid #ddd;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.ticket-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.ticket-header h3 {
  margin: 0;
  color: #333;
  font-size: 18px;
}

.status-badge {
  padding: 4px 8px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: bold;
  text-transform: uppercase;
}

.ticket-description {
  color: #666;
  margin: 12px 0;
  line-height: 1.5;
}

.ticket-meta {
  display: flex;
  justify-content: space-between;
  margin: 16px 0;
  color: #999;
  font-size: 12px;
}

.ticket-actions {
  display: flex;
  align-items: center;
  gap: 8px;
}

.status-select {
  padding: 4px 8px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 12px;
}

.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-content {
  background: white;
  border-radius: 8px;
  width: 90%;
  max-width: 500px;
  max-height: 90vh;
  overflow-y: auto;
}
</style>