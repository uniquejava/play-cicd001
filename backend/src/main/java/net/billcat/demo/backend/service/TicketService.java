package net.billcat.demo.backend.service;

import net.billcat.demo.backend.dto.CreateTicketRequest;
import net.billcat.demo.backend.dto.TicketDto;
import net.billcat.demo.backend.model.Ticket;
import net.billcat.demo.backend.model.TicketStatus;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;

@Service
public class TicketService {

    // 使用内存存储，无需数据库
    private final Map<Long, Ticket> tickets = new ConcurrentHashMap<>();
    private final AtomicLong idGenerator = new AtomicLong(1);

    // 初始化一些示例数据
    public TicketService() {
        // 创建几个示例tickets
        createTicket(new CreateTicketRequest("Setup CI/CD Pipeline", "Initial setup of GitHub Actions workflow"));
        createTicket(new CreateTicketRequest("Configure Kubernetes", "Set up K8s deployment manifests"));
        createTicket(new CreateTicketRequest("Implement Authentication", "Add JWT authentication to the system"));
    }

    public List<TicketDto> getAllTickets() {
        return tickets.values().stream()
                .map(this::convertToDto)
                .toList();
    }

    public Optional<TicketDto> getTicketById(Long id) {
        return Optional.ofNullable(tickets.get(id))
                .map(this::convertToDto);
    }

    public TicketDto createTicket(CreateTicketRequest request) {
        // 验证输入
        if (request.getTitle() == null || request.getTitle().trim().isEmpty()) {
            throw new IllegalArgumentException("Title cannot be empty");
        }

        Long id = idGenerator.getAndIncrement();
        Ticket ticket = new Ticket(id, request.getTitle(), request.getDescription());
        tickets.put(id, ticket);

        return convertToDto(ticket);
    }

    public Optional<TicketDto> updateTicket(Long id, CreateTicketRequest request) {
        Ticket existingTicket = tickets.get(id);
        if (existingTicket == null) {
            return Optional.empty();
        }

        // 验证输入
        if (request.getTitle() == null || request.getTitle().trim().isEmpty()) {
            throw new IllegalArgumentException("Title cannot be empty");
        }

        existingTicket.setTitle(request.getTitle());
        existingTicket.setDescription(request.getDescription());

        return Optional.of(convertToDto(existingTicket));
    }

    public Optional<TicketDto> updateTicketStatus(Long id, String status) {
        Ticket existingTicket = tickets.get(id);
        if (existingTicket == null) {
            return Optional.empty();
        }

        try {
            TicketStatus newStatus = TicketStatus.valueOf(status.toUpperCase());
            existingTicket.setStatus(newStatus);
            return Optional.of(convertToDto(existingTicket));
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("Invalid status. Must be one of: OPEN, IN_PROGRESS, CLOSED");
        }
    }

    public boolean deleteTicket(Long id) {
        return tickets.remove(id) != null;
    }

    private TicketDto convertToDto(Ticket ticket) {
        return new TicketDto(
                ticket.getId(),
                ticket.getTitle(),
                ticket.getDescription(),
                ticket.getStatus().name(),
                ticket.getCreatedAt(),
                ticket.getUpdatedAt()
        );
    }
}