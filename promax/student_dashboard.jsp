<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Alias redirecting to student/dashboard.jsp
    request.getRequestDispatcher("/student/dashboard.jsp").forward(request, response);
%>
