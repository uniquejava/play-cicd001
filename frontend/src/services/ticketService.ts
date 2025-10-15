import type {CreateTicketRequest, Ticket} from '@/types/ticket'

const API_BASE_URL = '/api/tickets'

class TicketService {
  async getAllTickets(): Promise<Ticket[]> {
    const response = await fetch(API_BASE_URL)
    if (!response.ok) {
      throw new Error('Failed to fetch tickets')
    }
    return response.json()
  }

  async getTicketById(id: number): Promise<Ticket> {
    const response = await fetch(`${API_BASE_URL}/${id}`)
    if (!response.ok) {
      throw new Error('Failed to fetch ticket')
    }
    return response.json()
  }

  async createTicket(ticket: CreateTicketRequest): Promise<Ticket> {
    const response = await fetch(API_BASE_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(ticket),
    })

    if (!response.ok) {
      const error = await response.json()
      throw new Error(error.error || 'Failed to create ticket')
    }

    return response.json()
  }

  async updateTicket(id: number, ticket: CreateTicketRequest): Promise<Ticket> {
    const response = await fetch(`${API_BASE_URL}/${id}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(ticket),
    })

    if (!response.ok) {
      const error = await response.json()
      throw new Error(error.error || 'Failed to update ticket')
    }

    return response.json()
  }

  async updateTicketStatus(id: number, status: string): Promise<Ticket> {
    const response = await fetch(`${API_BASE_URL}/${id}/status`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ status }),
    })

    if (!response.ok) {
      const error = await response.json()
      throw new Error(error.error || 'Failed to update ticket status')
    }

    return response.json()
  }

  async deleteTicket(id: number): Promise<void> {
    const response = await fetch(`${API_BASE_URL}/${id}`, {
      method: 'DELETE',
    })

    if (!response.ok) {
      throw new Error('Failed to delete ticket')
    }
  }
}

export const ticketService = new TicketService()