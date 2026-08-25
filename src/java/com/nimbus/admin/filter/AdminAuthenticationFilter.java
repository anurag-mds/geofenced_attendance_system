package com.nimbus.admin.filter;

import com.nimbus.admin.model.Employee;
import com.nimbus.admin.util.CsrfToken;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.DispatcherType;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Cookie;
import java.io.IOException;

@WebFilter("/*")
public class AdminAuthenticationFilter implements Filter {

	@Override
	public void doFilter(ServletRequest request, ServletResponse response,
			FilterChain chain) throws IOException, ServletException {
		HttpServletRequest httpRequest = (HttpServletRequest) request;
		HttpServletResponse httpResponse = (HttpServletResponse) response;
		preventBrowserCaching(httpResponse);
		String path = httpRequest.getRequestURI().substring(
				httpRequest.getContextPath().length());
		var session = httpRequest.getSession(false);
		boolean authenticated = session != null
				&& session.getAttribute("employee") instanceof Employee;
		boolean logoutTransition = "/logout-success.jsp".equals(path)
				&& Boolean.TRUE.equals(httpRequest.getAttribute("logoutTransition"));
		boolean directProtectedPage = httpRequest.getDispatcherType() == DispatcherType.REQUEST
				&& "/session-expired.jsp".equals(path);
		if (directProtectedPage && !logoutTransition) {
			httpResponse.sendRedirect(httpRequest.getContextPath()
					+ "/index.html?error=not_authenticated");
			return;
		}

		if (authenticated) {
			CsrfToken.getToken(httpRequest);
			if ("POST".equalsIgnoreCase(httpRequest.getMethod())
					&& !isPublicPath(path) && !CsrfToken.isValid(httpRequest)) {
				httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN,
						"Invalid request token.");
				return;
			}
		}

		if (logoutTransition
				|| isPublicPath(path)
				|| authenticated) {
			chain.doFilter(request, response);
			return;
		}

		if (hasAuthenticatedMarker(httpRequest)) {
			httpRequest.getRequestDispatcher("/session-expired.jsp").forward(request, response);
		} else {
			httpResponse.sendRedirect(httpRequest.getContextPath()
					+ "/index.html?error=not_authenticated");
		}
	}

	private boolean hasAuthenticatedMarker(HttpServletRequest request) {
		Cookie[] cookies = request.getCookies();
		if (cookies == null) return false;
		for (Cookie cookie : cookies) {
			if ("ATTENDANCE_AUTHENTICATED".equals(cookie.getName())
					&& "1".equals(cookie.getValue())) return true;
		}
		return false;
	}

	private boolean isPublicPath(String path) {
		return "/".equals(path)
				|| "/index.html".equals(path)
				|| "/manual-test-audit.html".equals(path)
				|| path.startsWith("/error-preview.jsp")
				|| "/LoginServlet".equals(path)
				|| "/AdminLoginServlet".equals(path)
				|| path.startsWith("/WEB-INF/");
	}

	private void preventBrowserCaching(HttpServletResponse response) {
		response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
		response.setHeader("Pragma", "no-cache");
		response.setDateHeader("Expires", 0);
	}
}
