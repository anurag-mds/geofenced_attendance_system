<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="com.nimbus.admin.model.ContactMessage" %>
<%@ page import="com.nimbus.admin.model.Employee" %>
<%@ page import="com.nimbus.admin.model.Role" %>
<%@ page import="com.nimbus.admin.util.HtmlEscaper" %>
<%@ page import="java.util.List" %>
<%
    Employee currentEmployee = (Employee) session.getAttribute("employee");
    List<Employee> contacts = (List<Employee>) request.getAttribute("contacts");
    Employee selectedContact = (Employee) request.getAttribute("selectedContact");
    List<ContactMessage> messages = (List<ContactMessage>) request.getAttribute("messages");
    Role contactRole = (Role) request.getAttribute("contactRole");
    boolean groupSelected = Boolean.TRUE.equals(request.getAttribute("groupSelected"));
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Contact <%= HtmlEscaper.text(contactRole) %></title>
    <%@ include file="/WEB-INF/jsp/common/nav-styles.jsp" %>
    <style>
        * { box-sizing: border-box; }
        body { margin: 0; font-family: Arial, sans-serif; background: #f2f4f7; color: #24292f; }
        .page-content { padding: 28px; }
        .contact-shell { max-width: 1120px; height: calc(100vh - 126px); min-height: 540px; margin: auto; display: grid; grid-template-columns: 270px 1fr; background: #fff; border: 1px solid #d0d7de; border-radius: 8px; overflow: hidden; }
        .people { border-right: 1px solid #d0d7de; background: #f6f8fa; overflow-y: auto; }
        .people h1 { font-size: 18px; padding: 20px; margin: 0; border-bottom: 1px solid #d0d7de; }
        .person { display: block; padding: 14px 18px; color: #24292f; text-decoration: none; border-bottom: 1px solid #eaeef2; }
        .person:hover, .person.selected { background: #fff; }
        .person strong { display: block; font-size: 14px; }
        .person span { color: #57606a; font-size: 12px; }
        .conversation { display: flex; flex-direction: column; min-width: 0; }
        .conversation-header { padding: 18px 22px; border-bottom: 1px solid #d0d7de; }
        .conversation-header h2 { margin: 0 0 4px; font-size: 18px; }
        .conversation-header p { margin: 0; color: #57606a; font-size: 13px; }
        .thread { flex: 1; overflow-y: auto; padding: 22px; background: #fff; }
        .message { max-width: 78%; margin-bottom: 18px; }
        .message.mine { margin-left: auto; }
        .message-meta { color: #57606a; font-size: 12px; margin-bottom: 5px; }
        .bubble { padding: 11px 13px; border: 1px solid #d0d7de; border-radius: 8px; background: #f6f8fa; white-space: pre-wrap; word-break: break-word; }
        .mine .bubble { background: #ddf4ff; border-color: #54aeff; }
        .attachment-card { display: flex; align-items: center; gap: 10px; max-width: 320px; margin-top: 9px; padding: 10px 12px; border: 1px solid #8c959f; border-radius: 8px; background: #fff; color: #24292f; text-decoration: none; }
        .mine .attachment-card { border-color: #54aeff; }
        .attachment-card:hover { background: #f6f8fa; }
        .attachment-icon { display: grid; width: 32px; height: 32px; flex: 0 0 32px; place-items: center; border-radius: 6px; background: #ddf4ff; color: #0969da; font-size: 18px; }
        .attachment-label { min-width: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; font-size: 13px; }
        .attachment-action { margin-left: auto; padding: 0; border: 0; background: transparent; color: #0969da; font: inherit; font-size: 12px; white-space: nowrap; }
        .attachment-action:hover { background: transparent; color: #0550ae; text-decoration: underline; }
        .attachment-viewer { position: fixed; inset: 0; z-index: 10; display: none; place-items: center; padding: 5vh 5vw; background: rgba(27,31,36,.72); }
        .attachment-viewer.visible { display: grid; }
        .attachment-viewer-panel { width: min(960px, 100%); height: min(88vh, 760px); position: relative; padding: 42px 12px 12px; background: #fff; border-radius: 8px; }
        .attachment-viewer iframe { width: 100%; height: 100%; border: 0; }
        .attachment-viewer-close { position: absolute; top: 8px; right: 10px; padding: 4px 10px; border: 0; background: transparent; color: #24292f; font-size: 24px; }
        .composer { padding: 16px 22px; border-top: 1px solid #d0d7de; background: #f6f8fa; }
        .composer textarea { width: 100%; min-height: 72px; resize: vertical; padding: 10px; border: 1px solid #8c959f; border-radius: 6px; font: inherit; }
        .composer-actions { display: flex; align-items: center; justify-content: space-between; gap: 12px; margin-top: 10px; }
        .attachment-picker { display: flex; align-items: center; gap: 10px; min-width: 0; }
        .attachment-button { padding: 9px 12px; border: 1px solid #8c959f; background: #fff; color: #24292f; }
        .attachment-button:hover { background: #eaeef2; }
        .attachment-input { position: absolute; width: 1px; height: 1px; opacity: 0; pointer-events: none; }
        .attachment-preview { display: none; align-items: center; gap: 8px; max-width: 280px; padding: 7px 10px; border: 1px solid #54aeff; border-radius: 8px; background: #ddf4ff; font-size: 12px; }
        .attachment-preview.visible { display: flex; }
        .attachment-preview span { overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .attachment-remove { padding: 0 5px; border: 0; background: transparent; color: #cf222e; font-size: 18px; }
        .mention-picker { position: relative; margin-bottom: 10px; }
        .mention-suggestions { position: absolute; left: 0; right: 0; bottom: 78px; z-index: 2; background: #fff; border: 1px solid #d0d7de; border-radius: 6px; box-shadow: 0 4px 12px rgba(27,31,36,.15); }
        .mention-suggestions button { display: block; width: 100%; border: 0; border-radius: 0; background: #fff; color: #24292f; text-align: left; }
        .mention-suggestions button:hover { background: #ddf4ff; }
        .tagged-list { display: flex; gap: 6px; flex-wrap: wrap; margin: 8px 0; }
        .tagged-list label { padding: 4px 8px; border: 1px solid #54aeff; border-radius: 999px; background: #ddf4ff; font-size: 12px; }
        button { padding: 9px 15px; border: 1px solid #1f2328; border-radius: 6px; background: #1f2328; color: #fff; cursor: pointer; }
        .tag-help { color: #57606a; font-size: 12px; margin: 0 0 10px; }
        .error { padding: 10px 14px; color: #cf222e; background: #ffebe9; border-bottom: 1px solid #ff8182; }
        .conversation-actions { display: flex; justify-content: flex-end; padding: 10px 22px 0; background: #fff; }
        .clear-chat { padding: 7px 11px; border: 1px solid #cf222e; border-radius: 6px; background: #fff; color: #cf222e; font-size: 12px; cursor: pointer; }
        .clear-chat:hover { background: #fff1f0; }
        .clear-dialog[hidden] { display: none; }
        .clear-dialog { position: fixed; inset: 0; z-index: 2000; display: grid; place-items: center; padding: 20px; }
        .clear-dialog-backdrop { position: absolute; inset: 0; background: rgba(0, 0, 0, .72); backdrop-filter: blur(4px); }
        .clear-dialog-panel { position: relative; width: min(440px, 100%); padding: 30px; background: #fff; color: #171717; border: 1px solid #171717; box-shadow: 12px 12px 0 #000; }
        .clear-dialog-panel h2 { margin: 0 0 10px; font-size: 24px; }
        .clear-dialog-panel p { line-height: 1.5; }
        .clear-dialog-actions { display: flex; justify-content: flex-end; gap: 10px; margin-top: 24px; }
        .clear-dialog-actions button { min-width: 110px; }
        .clear-dialog-cancel { background: #fff; color: #171717; }
        .clear-dialog-confirm { background: #cf222e; border-color: #cf222e; color: #fff; }
        @media (max-width: 760px) { .page-content { padding: 12px; } .contact-shell { height: calc(100vh - 94px); grid-template-columns: 1fr; } .people { max-height: 170px; border-right: 0; border-bottom: 1px solid #d0d7de; } .people h1 { padding: 12px 16px; } .person { display: inline-block; width: auto; min-width: 150px; border-bottom: 0; } }
    </style>
</head>
<body>
    <%@ include file="/WEB-INF/jsp/common/app-nav.jsp" %>
    <main class="page-content">
        <section class="contact-shell">
            <aside class="people">
                <h1>Chats</h1>
                <a class="person <%= groupSelected ? "selected" : "" %>" href="<%= request.getContextPath() %>/ContactServlet?contactWith=group">
                    <strong>Admin + HR group</strong><span>Everyone in the Admin and HR teams</span>
                </a>
                <% if (contacts != null) { for (Employee contact : contacts) { %>
                    <a class="person <%= selectedContact != null && selectedContact.getEmpId() == contact.getEmpId() ? "selected" : "" %>" href="<%= request.getContextPath() %>/ContactServlet?contactWith=<%= contact.getEmpId() %>">
                        <strong><%= HtmlEscaper.text(contact.getFullName()) %></strong><span><%= HtmlEscaper.text(contact.getEmpCode()) %> · <%= HtmlEscaper.text(contact.getEmail()) %></span>
                    </a>
                <% }} %>
            </aside>
            <section class="conversation">
                <% if (selectedContact == null && !groupSelected) { %>
                    <div class="conversation-header"><h2>No contact available</h2><p>Add an HR representative or Admin account first.</p></div>
                <% } else { %>
                    <% if (groupSelected) { %>
                        <header class="conversation-header"><h2>Admin + HR group</h2><p>One shared conversation for all active Admin and HR members.</p></header>
                    <% } else { %>
                        <header class="conversation-header"><h2><%= HtmlEscaper.text(selectedContact.getFullName()) %></h2><p><%= HtmlEscaper.text(selectedContact.getRole()) %> · <%= HtmlEscaper.text(selectedContact.getEmail()) %></p></header>
                    <% } %>
                    <% if ("message".equals(error)) { %><div class="error">Choose a recipient and enter a message or attach a file.</div><% } %>
                    <% if ("attachment".equals(error)) { %><div class="error">Choose a valid file smaller than 10 MB.</div><% } %>
                    <% if ("cleared".equals(request.getParameter("success"))) { %><div class="tag-help">Conversation cleared.</div><% } %>
                    <div class="conversation-actions"><form class="clear-chat-form" method="post" action="<%= request.getContextPath() %>/ContactServlet"><input type="hidden" name="csrfToken" value="<%= com.nimbus.admin.util.CsrfToken.getToken(request) %>"><input type="hidden" name="action" value="clear"><input type="hidden" name="conversationId" value="<%= groupSelected ? "group" : "direct" %>"><% if (!groupSelected) { %><input type="hidden" name="recipientId" value="<%= selectedContact.getEmpId() %>"><% } %><button class="clear-chat" type="submit">Clear Chat</button></form></div>
                    <div class="thread">
                        <% if (messages == null || messages.isEmpty()) { %><p class="tag-help">Start the conversation. Admins can select multiple HRs to tag on the left.</p><% } %>
                        <% if (messages != null) { for (ContactMessage item : messages) { %>
                            <article class="message <%= item.getSenderId() == currentEmployee.getEmpId() ? "mine" : "" %>">
                                <div class="message-meta"><%= HtmlEscaper.text(item.getSenderName()) %> · <%= HtmlEscaper.text(item.getCreatedAt()) %></div>
                                <% if (item.getMessage() != null && !item.getMessage().isBlank()) { %><div class="bubble"><%= HtmlEscaper.text(item.getMessage()) %></div><% } %>
                                <% if (item.getAttachmentName() != null) { String attachmentUrl = request.getContextPath() + "/ContactServlet?messageId=" + item.getMessageId() + "&file=" + java.net.URLEncoder.encode(item.getAttachmentName(), "UTF-8"); String attachmentLower = item.getAttachmentName().toLowerCase(); boolean canPreview = attachmentLower.endsWith(".pdf") || attachmentLower.matches(".*\\.(png|jpe?g|gif|webp)$"); %><div class="attachment-card"><span class="attachment-icon" aria-hidden="true">&#128206;</span><span class="attachment-label"><%= HtmlEscaper.text(item.getAttachmentName()) %></span><% if (canPreview) { %><button class="attachment-action" type="button" data-preview-url="<%= attachmentUrl %>&view=1">View</button><% } %><a class="attachment-action" href="<%= attachmentUrl %>" download>Download</a></div><% } %>
                            </article>
                        <% }} %>
                    </div>
                    <form class="composer" method="post" enctype="multipart/form-data" action="<%= request.getContextPath() %>/ContactServlet">
                        <input type="hidden" name="csrfToken" value="<%= com.nimbus.admin.util.CsrfToken.getToken(request) %>">
                        <input type="hidden" name="conversationId" value="<%= groupSelected ? "group" : "direct" %>">
                        <% if (groupSelected) { %>
                            <p class="tag-help">Everyone in the Admin + HR group can see this conversation.</p>
                        <% } else { %>
                            <input type="hidden" name="recipientId" value="<%= selectedContact.getEmpId() %>">
                        <% } %>
                        <% if (currentEmployee.getRole() == Role.ADMIN && groupSelected) { %>
                            <p class="tag-help">Type <strong>@</strong> to mention an HR in this shared conversation.</p>
                            <div id="taggedList" class="tagged-list">
                                <% for (Employee contact : contacts) { %>
                                    <label><input type="checkbox" name="recipientId" value="<%= contact.getEmpId() %>" checked> @<%= HtmlEscaper.text(contact.getEmpCode()) %></label>
                                <% } %>
                            </div>
                        <% } %>
                        <div class="mention-picker">
                            <textarea id="messageBox" name="message" placeholder="Write a message...<%= currentEmployee.getRole() == Role.ADMIN && groupSelected ? " Type @ to mention an HR." : "" %>" maxlength="5000"></textarea>
                            <% if (currentEmployee.getRole() == Role.ADMIN && groupSelected) { %><div id="mentionSuggestions" class="mention-suggestions" hidden></div><% } %>
                        </div>
                        <div class="composer-actions">
                            <div class="attachment-picker">
                                <label class="attachment-button" for="attachmentInput">Attach file</label>
                                <input class="attachment-input" id="attachmentInput" type="file" name="attachment" accept="image/*,.pdf,.doc,.docx,.xls,.xlsx,.ppt,.pptx,.txt,.zip">
                                <div class="attachment-preview" id="attachmentPreview"><span id="attachmentName"></span><button class="attachment-remove" type="button" id="removeAttachment" aria-label="Remove attachment">&times;</button></div>
                            </div>
                            <button type="submit">Send message</button>
                        </div>
                    </form>
                <% } %>
            </section>
        </section>
    </main>
    <div class="attachment-viewer" id="attachmentViewer" hidden>
        <section class="attachment-viewer-panel" role="dialog" aria-modal="true" aria-label="Attachment preview">
            <button class="attachment-viewer-close" type="button" id="closeAttachmentViewer" aria-label="Close preview">&times;</button>
            <iframe id="attachmentFrame" title="Attachment preview"></iframe>
        </section>
    </div>
    <div class="clear-dialog" id="clearDialog" hidden>
        <div class="clear-dialog-backdrop" data-close-clear-dialog></div>
        <section class="clear-dialog-panel" role="dialog" aria-modal="true" aria-labelledby="clearDialogTitle">
            <h2 id="clearDialogTitle">Clear conversation?</h2>
            <p>All messages in this conversation will be removed.</p>
            <div class="clear-dialog-actions">
                <button class="clear-dialog-cancel" type="button" data-close-clear-dialog>Cancel</button>
                <button class="clear-dialog-confirm" type="button" id="confirmClearChat">Clear Chat</button>
            </div>
        </section>
    </div>
    <% if (currentEmployee.getRole() == Role.ADMIN) { %>
    <div id="contactData" hidden>
        <% for (Employee contact : contacts) { %>
            <span data-contact data-id="<%= contact.getEmpId() %>"
                  data-code="<%= HtmlEscaper.text(contact.getEmpCode()) %>"
                  data-name="<%= HtmlEscaper.text(contact.getFullName()) %>"></span>
        <% } %>
    </div>
    <script>
        const messageBox = document.getElementById('messageBox');
        const suggestions = document.getElementById('mentionSuggestions');
        const taggedList = document.getElementById('taggedList');
        let tagSelectionStarted = false;
        const hrContacts = Array.from(document.querySelectorAll('#contactData [data-contact]'))
            .map(contact => ({
                id: contact.dataset.id,
                code: contact.dataset.code,
                name: contact.dataset.name
            }));
        function renderSuggestions() {
            const mention = messageBox.value.match(/@([A-Za-z0-9_]*)$/);
            if (!mention) {
                suggestions.hidden = true;
                return;
            }
            const query = mention[1].toLowerCase();
            const matches = hrContacts.filter(contact => (contact.code + ' ' + contact.name).toLowerCase().includes(query));
            suggestions.innerHTML = '';
            matches.forEach(contact => {
                const button = document.createElement('button');
                button.type = 'button';
                button.textContent = '@' + contact.code + ' - ' + contact.name;
                button.addEventListener('click', () => {
                    if (!tagSelectionStarted) {
                        taggedList.querySelectorAll('input[name="recipientId"]').forEach(input => input.checked = false);
                        tagSelectionStarted = true;
                    }
                    if (!taggedList.querySelector('input[value="' + CSS.escape(contact.id) + '"]')) {
                        const label = document.createElement('label');
                        const input = document.createElement('input');
                        input.type = 'checkbox';
                        input.name = 'recipientId';
                        input.value = contact.id;
                        input.checked = true;
                        label.append(input, document.createTextNode(' @' + contact.code));
                        taggedList.appendChild(label);
                    }
                    const mention = messageBox.value.match(/@([A-Za-z0-9_]*)$/);
                    messageBox.value = messageBox.value.slice(0, mention.index) + '@' + contact.code + ' ';
                    messageBox.focus();
                    suggestions.hidden = true;
                });
                suggestions.appendChild(button);
            });
            suggestions.hidden = matches.length === 0;
        }
        messageBox.addEventListener('input', renderSuggestions);
        document.addEventListener('click', event => { if (!event.target.closest('.mention-picker')) suggestions.hidden = true; });
    </script>
    <% } %>
    <script>
        const attachmentViewer = document.getElementById('attachmentViewer');
        const attachmentFrame = document.getElementById('attachmentFrame');
        const closeAttachmentViewer = document.getElementById('closeAttachmentViewer');
        document.querySelectorAll('[data-preview-url]').forEach(function (button) {
            button.addEventListener('click', function () {
                attachmentFrame.src = button.dataset.previewUrl;
                attachmentViewer.hidden = false;
                attachmentViewer.classList.add('visible');
            });
        });
        function closePreview() {
            attachmentViewer.classList.remove('visible');
            attachmentViewer.hidden = true;
            attachmentFrame.src = 'about:blank';
        }
        closeAttachmentViewer.addEventListener('click', closePreview);
        attachmentViewer.addEventListener('click', function (event) { if (event.target === attachmentViewer) closePreview(); });

        const clearDialog = document.getElementById('clearDialog');
        const clearForm = document.querySelector('.clear-chat-form');
        const confirmClearChat = document.getElementById('confirmClearChat');
        function closeClearDialog() {
            if (clearDialog) clearDialog.hidden = true;
        }
        if (clearForm && clearDialog && confirmClearChat) {
            clearForm.addEventListener('submit', function (event) {
                event.preventDefault();
                clearDialog.hidden = false;
                confirmClearChat.focus();
            });
            confirmClearChat.addEventListener('click', function () {
                clearForm.submit();
            });
            clearDialog.querySelectorAll('[data-close-clear-dialog]').forEach(function (element) {
                element.addEventListener('click', closeClearDialog);
            });
        }

        const attachmentInput = document.getElementById('attachmentInput');
        const attachmentPreview = document.getElementById('attachmentPreview');
        const attachmentName = document.getElementById('attachmentName');
        const removeAttachment = document.getElementById('removeAttachment');
        if (attachmentInput) {
            attachmentInput.addEventListener('change', function () {
                const file = attachmentInput.files[0];
                if (!file) return;
                if (file.size > 10 * 1024 * 1024) {
                    attachmentInput.value = '';
                    attachmentName.textContent = 'File must be smaller than 10 MB.';
                    attachmentPreview.classList.add('visible');
                    return;
                }
                attachmentName.textContent = file.name + ' (' + Math.ceil(file.size / 1024) + ' KB)';
                attachmentPreview.classList.add('visible');
            });
            removeAttachment.addEventListener('click', function () {
                attachmentInput.value = '';
                attachmentPreview.classList.remove('visible');
                attachmentName.textContent = '';
            });
        }
    </script>
</body>
</html>