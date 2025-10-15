export interface Ticket {
  id: number
  title: string
  description: string
  status: 'OPEN' | 'IN_PROGRESS' | 'CLOSED'
  createdAt: string
  updatedAt: string
}

export interface CreateTicketRequest {
  title: string
  description: string
}

export interface ApiResponse<T> {
  data?: T
  error?: string
}