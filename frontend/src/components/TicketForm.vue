<script setup lang="ts">
import { ref, watch } from 'vue'
import { ticketService } from '@/services/ticketService'
import type { Ticket, CreateTicketRequest } from '@/types/ticket'

const props = defineProps<{
  ticket?: Ticket | null
}>()

const emit = defineEmits<{
  submit: []
  cancel: []
}>()

const title = ref('')
const description = ref('')
const loading = ref(false)
const error = ref('')

// If editing existing ticket, populate form
watch(() => props.ticket, (ticket) => {
  if (ticket) {
    title.value = ticket.title
    description.value = ticket.description || ''
  } else {
    title.value = ''
    description.value = ''
  }
}, { immediate: true })

const handleSubmit = async () => {
  if (!title.value.trim()) {
    error.value = 'Title is required'
    return
  }

  loading.value = true
  error.value = ''

  try {
    const ticketData: CreateTicketRequest = {
      title: title.value.trim(),
      description: description.value.trim()
    }

    if (props.ticket) {
      await ticketService.updateTicket(props.ticket.id, ticketData)
    } else {
      await ticketService.createTicket(ticketData)
    }

    emit('submit')
  } catch (err) {
    error.value = err instanceof Error ? err.message : 'Failed to save ticket'
  } finally {
    loading.value = false
  }
}

const handleCancel = () => {
  emit('cancel')
}
</script>

<template>
  <div class="ticket-form">
    <h3>{{ ticket ? 'Edit Ticket' : 'Create New Ticket' }}</h3>

    <form @submit.prevent="handleSubmit">
      <div class="form-group">
        <label for="title">Title *</label>
        <input
          id="title"
          v-model="title"
          type="text"
          required
          placeholder="Enter ticket title"
          :disabled="loading"
        />
      </div>

      <div class="form-group">
        <label for="description">Description</label>
        <textarea
          id="description"
          v-model="description"
          rows="4"
          placeholder="Enter ticket description (optional)"
          :disabled="loading"
        ></textarea>
      </div>

      <div v-if="error" class="error">
        {{ error }}
      </div>

      <div class="form-actions">
        <button
          type="button"
          @click="handleCancel"
          class="btn btn-secondary"
          :disabled="loading"
        >
          Cancel
        </button>

        <button
          type="submit"
          class="btn btn-primary"
          :disabled="loading"
        >
          {{ loading ? 'Saving...' : (ticket ? 'Update' : 'Create') }}
        </button>
      </div>
    </form>
  </div>
</template>

<style scoped>
.ticket-form {
  padding: 20px;
}

.ticket-form h3 {
  margin: 0 0 20px 0;
  color: #333;
}

.form-group {
  margin-bottom: 16px;
}

.form-group label {
  display: block;
  margin-bottom: 6px;
  font-weight: 600;
  color: #333;
}

.form-group input,
.form-group textarea {
  width: 100%;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
  font-family: inherit;
  box-sizing: border-box;
}

.form-group input:focus,
.form-group textarea:focus {
  outline: none;
  border-color: #007bff;
  box-shadow: 0 0 0 2px rgba(0, 123, 255, 0.25);
}

.form-group input:disabled,
.form-group textarea:disabled {
  background-color: #f8f9fa;
  color: #6c757d;
}

.error {
  background-color: #f8d7da;
  color: #721c24;
  padding: 12px;
  border-radius: 4px;
  margin-bottom: 16px;
  font-size: 14px;
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  margin-top: 24px;
}

.btn {
  padding: 10px 20px;
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

.btn-primary:hover:not(:disabled) {
  background-color: #0056b3;
}

.btn-primary:disabled {
  background-color: #6c757d;
  cursor: not-allowed;
}

.btn-secondary {
  background-color: #6c757d;
  color: white;
}

.btn-secondary:hover:not(:disabled) {
  background-color: #545b62;
}

.btn-secondary:disabled {
  background-color: #adb5bd;
  cursor: not-allowed;
}
</style>