package net.billcat.demo.backend.dto;

public class CreateTicketRequest {
    private String title;
    private String description;

    // Constructors
    public CreateTicketRequest() {}

    public CreateTicketRequest(String title, String description) {
        this.title = title;
        this.description = description;
    }

    // Getters and Setters
    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }
}