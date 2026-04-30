import Foundation
import OpenConnectKit

@Observable
@MainActor
final class VpnHandler: VpnSessionDelegate {

  // MARK: - Pending Interactive State

  /// Non-nil when an auth form is waiting for user input. Drives the auth sheet.
  var pendingAuthForm: AuthenticationForm?

  /// Non-nil when a certificate needs validation. Drives the cert alert.
  var pendingCertInfo: CertificateInfo?

  // MARK: - Continuations

  @ObservationIgnored
  private var authContinuation: CheckedContinuation<AuthenticationForm?, Never>?

  @ObservationIgnored
  private var certContinuation: CheckedContinuation<Bool, Never>?

  // MARK: - VpnSessionDelegate

  func vpnSession(
    _ session: VpnSession,
    requiresAuthentication form: AuthenticationForm
  ) async -> AuthenticationForm? {
    pendingAuthForm = form
    return await withCheckedContinuation { continuation in
      authContinuation = continuation
    }
  }

  func vpnSession(
    _ session: VpnSession,
    shouldAcceptCertificate info: CertificateInfo
  ) async -> Bool {
    pendingCertInfo = info
    return await withCheckedContinuation { continuation in
      certContinuation = continuation
    }
  }

  // MARK: - Auth Actions

  func submitAuth(_ form: AuthenticationForm) {
    authContinuation?.resume(returning: form)
    authContinuation = nil
    pendingAuthForm = nil
  }

  func cancelAuth() {
    authContinuation?.resume(returning: nil)
    authContinuation = nil
    pendingAuthForm = nil
  }

  // MARK: - Certificate Actions

  func acceptCertificate() {
    certContinuation?.resume(returning: true)
    certContinuation = nil
    pendingCertInfo = nil
  }

  func rejectCertificate() {
    certContinuation?.resume(returning: false)
    certContinuation = nil
    pendingCertInfo = nil
  }
}
