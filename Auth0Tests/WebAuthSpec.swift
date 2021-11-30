import Quick
import Nimble
import SafariServices

@testable import Auth0

private let ClientId = "ClientId"
private let Domain = "samples.auth0.com"
private let DomainURL = URL.httpsURL(from: Domain)
private let RedirectURL = URL(string: "https://samples.auth0.com/callback")!
private let State = "state"

extension URL {
    var a0_components: URLComponents? {
        return URLComponents(url: self, resolvingAgainstBaseURL: true)
    }
}

private let ValidAuthorizeURLExample = "valid authorize url"
class WebAuthSharedExamplesConfiguration: QuickConfiguration {
    override class func configure(_ configuration: Configuration) {
        sharedExamples(ValidAuthorizeURLExample) { (context: SharedExampleContext) in
            let attrs = context()
            let url = attrs["url"] as! URL
            let params = attrs["query"] as! [String: String]
            let domain = attrs["domain"] as! String
            let components = url.a0_components

            it("should use domain \(domain)") {
                expect(components?.scheme) == "https"
                expect(components?.host) == String(domain.split(separator: "/").first!)
                expect(components?.path).to(endWith("/authorize"))
            }

            it("should have state parameter") {
                expect(components?.queryItems).to(containItem(withName:"state"))
            }

            params.forEach { key, value in
                it("should have query parameter \(key)") {
                    expect(components?.queryItems).to(containItem(withName: key, value: value))
                }
            }
        }
    }
}

private func newWebAuth() -> Auth0WebAuth {
    return Auth0WebAuth(clientId: ClientId, url: DomainURL)
}

private func defaultQuery(withParameters parameters: [String: String] = [:]) -> [String: String] {
    var query = [
        "client_id": ClientId,
        "response_type": "code",
        "redirect_uri": RedirectURL.absoluteString,
        "scope": defaultScope,
    ]
    parameters.forEach { query[$0] = $1 }
    return query
}

private let defaults = ["response_type": "code"]

class WebAuthSpec: QuickSpec {

    override func spec() {

        describe("init") {

            it("should init with client id & url") {
                let webAuth = Auth0WebAuth(clientId: ClientId, url: DomainURL)
                expect(webAuth.clientId) == ClientId
                expect(webAuth.url) == DomainURL
            }

            it("should init with client id, url & session") {
                let session = URLSession(configuration: URLSession.shared.configuration)
                let webAuth = Auth0WebAuth(clientId: ClientId, url: DomainURL, session: session)
                expect(webAuth.session).to(be(session))
            }

            it("should init with client id, url & storage") {
                let storage = TransactionStore()
                let webAuth = Auth0WebAuth(clientId: ClientId, url: DomainURL, storage: storage)
                expect(webAuth.storage).to(be(storage))
            }

            it("should init with client id, url & telemetry") {
                let telemetryInfo = "info"
                var telemetry = Telemetry()
                telemetry.info = telemetryInfo
                let webAuth = Auth0WebAuth(clientId: ClientId, url: DomainURL, telemetry: telemetry)
                expect(webAuth.telemetry.info) == telemetryInfo
            }

        }

        describe("authorize URL") {

            itBehavesLike(ValidAuthorizeURLExample) {
                return [
                    "url": newWebAuth()
                        .buildAuthorizeURL(withRedirectURL: RedirectURL, defaults: defaults, state: State, organization: nil, invitation: nil),
                    "domain": Domain,
                    "query": defaultQuery(),
                ]
            }

            itBehavesLike(ValidAuthorizeURLExample) {
                return [
                    "url": newWebAuth()
                        .buildAuthorizeURL(withRedirectURL: RedirectURL, defaults: defaults, state: State, organization: nil, invitation: nil),
                    "domain": "\(Domain)/foo",
                    "query": defaultQuery()
                ]
            }

            itBehavesLike(ValidAuthorizeURLExample) {
                return [
                    "url": newWebAuth()
                        .buildAuthorizeURL(withRedirectURL: RedirectURL, defaults: defaults, state: State, organization: nil, invitation: nil),
                    "domain": "\(Domain)/foo/",
                    "query": defaultQuery()
                ]
            }

            itBehavesLike(ValidAuthorizeURLExample) {
                return [
                    "url": newWebAuth()
                        .buildAuthorizeURL(withRedirectURL: RedirectURL, defaults: defaults, state: State, organization: nil, invitation: nil),
                    "domain": "\(Domain)/foo/bar",
                    "query": defaultQuery()
                ]
            }

            itBehavesLike(ValidAuthorizeURLExample) {
                return [
                    "url": newWebAuth()
                        .buildAuthorizeURL(withRedirectURL: RedirectURL, defaults: defaults, state: State, organization: nil, invitation: nil),
                    "domain": "\(Domain)/foo/bar/",
                    "query": defaultQuery()
                ]
            }

            itBehavesLike(ValidAuthorizeURLExample) {
                return [
                    "url": newWebAuth()
                        .connection("facebook")
                        .buildAuthorizeURL(withRedirectURL: RedirectURL, defaults: defaults, state: State, organization: nil, invitation: nil),
                    "domain": Domain,
                    "query": defaultQuery(withParameters: ["connection": "facebook"]),
                ]
            }

            itBehavesLike(ValidAuthorizeURLExample) {
                return [
                    "url": newWebAuth()
                        .scope("openid email")
                        .buildAuthorizeURL(withRedirectURL: RedirectURL, defaults: defaults, state: State, organization: nil, invitation: nil),
                    "domain": Domain,
                    "query": defaultQuery(withParameters: ["scope": "openid email"]),
                ]
            }

            itBehavesLike(ValidAuthorizeURLExample) {
                let state = UUID().uuidString
                return [
                    "url": newWebAuth()
                        .parameters(["state": state])
                        .buildAuthorizeURL(withRedirectURL: RedirectURL, defaults: defaults, state: State, organization: nil, invitation: nil),
                    "domain": Domain,
                    "query": defaultQuery(withParameters: ["state": state]),
                ]
            }

            itBehavesLike(ValidAuthorizeURLExample) {
                return [
                    "url": newWebAuth()
                        .parameters(["scope": "openid email phone"])
                        .buildAuthorizeURL(withRedirectURL: RedirectURL, defaults: defaults, state: State, organization: nil, invitation: nil),
                    "domain": Domain,
                    "query": defaultQuery(withParameters: ["scope": "openid email phone"]),
                ]
            }

            itBehavesLike(ValidAuthorizeURLExample) {
                return [
                    "url": newWebAuth()
                        .parameters(["scope": "email phone"])
                        .buildAuthorizeURL(withRedirectURL: RedirectURL, defaults: defaults, state: State, organization: nil, invitation: nil),
                    "domain": Domain,
                    "query": defaultQuery(withParameters: ["scope": "openid email phone"]),
                ]
            }

            itBehavesLike(ValidAuthorizeURLExample) {
                return [
                    "url": newWebAuth()
                        .maxAge(10000) // 1 second
                        .buildAuthorizeURL(withRedirectURL: RedirectURL, defaults: defaults, state: State, organization: nil, invitation: nil),
                    "domain": Domain,
                    "query": defaultQuery(withParameters: ["max_age": "10000"]),
                ]
            }

            itBehavesLike(ValidAuthorizeURLExample) {
                return [
                    "url": newWebAuth()
                        .buildAuthorizeURL(withRedirectURL: RedirectURL, defaults: defaults, state: State, organization: "abc1234", invitation: nil),
                    "domain": Domain,
                    "query": defaultQuery(withParameters: ["organization": "abc1234"]),
                ]
            }

            itBehavesLike(ValidAuthorizeURLExample) {
                return [
                    "url": newWebAuth()
                        .buildAuthorizeURL(withRedirectURL: RedirectURL, defaults: defaults, state: State, organization: "abc1234", invitation: "xyz6789"),
                    "domain": Domain,
                    "query": defaultQuery(withParameters: ["organization": "abc1234", "invitation": "xyz6789"]),
                ]
            }

            itBehavesLike(ValidAuthorizeURLExample) {
                var newDefaults = defaults
                newDefaults["audience"] = "https://wwww.google.com"
                return [
                    "url": newWebAuth()
                        .buildAuthorizeURL(withRedirectURL: RedirectURL, defaults: newDefaults, state: State, organization: nil, invitation: nil),
                    "domain": Domain,
                    "query": defaultQuery(withParameters: ["audience": "https://wwww.google.com"]),
                ]
            }

            itBehavesLike(ValidAuthorizeURLExample) {
                var newDefaults = defaults
                newDefaults["audience"] = "https://wwww.google.com"
                return [
                    "url": newWebAuth()
                        .audience("https://domain.auth0.com")
                        .buildAuthorizeURL(withRedirectURL: RedirectURL, defaults: newDefaults, state: State, organization: nil, invitation: nil),
                    "domain": Domain,
                    "query": defaultQuery(withParameters: ["audience": "https://domain.auth0.com"]),
                ]
            }

            itBehavesLike(ValidAuthorizeURLExample) {
                return [
                    "url": newWebAuth()
                        .audience("https://domain.auth0.com")
                        .buildAuthorizeURL(withRedirectURL: RedirectURL, defaults: defaults, state: State, organization: nil, invitation: nil),
                    "domain": Domain,
                    "query": defaultQuery(withParameters: ["audience": "https://domain.auth0.com"]),
                ]
            }

            itBehavesLike(ValidAuthorizeURLExample) {
                return [
                    "url": newWebAuth()
                        .connectionScope("user_friends,email")
                        .buildAuthorizeURL(withRedirectURL: RedirectURL, defaults: defaults, state: State, organization: nil, invitation: nil),
                    "domain": Domain,
                    "query": defaultQuery(withParameters: ["connection_scope": "user_friends,email"]),
                ]
            }

            itBehavesLike(ValidAuthorizeURLExample) {
                var newDefaults = defaults
                newDefaults["connection_scope"] = "email"
                return [
                    "url": newWebAuth()
                        .connectionScope("user_friends")
                        .buildAuthorizeURL(withRedirectURL: RedirectURL, defaults: newDefaults, state: State, organization: nil, invitation: nil),
                    "domain": Domain,
                    "query": defaultQuery(withParameters: ["connection_scope": "user_friends"]),
                ]
            }

            context("encoding") {
                
                it("should encode + as %2B"){
                    let url = newWebAuth()
                            .parameters(["login_hint": "first+last@host.com"])
                            .buildAuthorizeURL(withRedirectURL: RedirectURL, defaults: defaults, state: State, organization: nil, invitation: nil)
                    expect(url.absoluteString.contains("first%2Blast@host.com")).to(beTrue())
                }
                
            }

        }

        describe("redirect uri") {
            #if os(iOS)
            let platform = "ios"
            #else
            let platform = "macos"
            #endif

            context("custom scheme") {

                let bundleId = Bundle.main.bundleIdentifier!

                it("should build with the domain") {
                    expect(newWebAuth().redirectURL?.absoluteString) == "\(bundleId)://\(Domain)/\(platform)/\(bundleId)/callback"
                }

                it("should build with the domain and a subpath") {
                    let subpath = "foo"
                    let uri = "\(bundleId)://\(Domain)/\(subpath)/\(platform)/\(bundleId)/callback"
                    let webAuth = Auth0WebAuth(clientId: ClientId, url: DomainURL.appendingPathComponent(subpath))
                    expect(webAuth.redirectURL?.absoluteString) == uri
                }

                it("should build with the domain and subpaths") {
                    let subpaths = "foo/bar"
                    let uri = "\(bundleId)://\(Domain)/\(subpaths)/\(platform)/\(bundleId)/callback"
                    let webAuth = Auth0WebAuth(clientId: ClientId, url: DomainURL.appendingPathComponent(subpaths))
                    expect(webAuth.redirectURL?.absoluteString) == uri
                }

            }

            it("should build with a custom url") {
                expect(newWebAuth().redirectURL(RedirectURL).redirectURL) == RedirectURL
            }

        }

        describe("other builder methods") {

            context("leeway") {

                it("should use the default leeway value") {
                    expect(newWebAuth().leeway).to(equal(60000)) // 60 seconds
                }

                it("should use a custom leeway value") {
                    expect(newWebAuth().leeway(30000).leeway).to(equal(30000)) // 30 seconds
                }

            }

            context("issuer") {

                it("should use the default issuer value") {
                    expect(newWebAuth().issuer).to(equal("\(DomainURL.absoluteString)/"))
                }

                it("should use a custom issuer value") {
                    expect(newWebAuth().issuer("https://example.com/").issuer).to(equal("https://example.com/"))
                }

            }

            context("organization") {

                it("should use no organization value by default") {
                    expect(newWebAuth().organization).to(beNil())
                }

                it("should use an organization value") {
                    expect(newWebAuth().organization("abc1234").organization).to(equal("abc1234"))
                }

            }

            context("organization invitation") {

                it("should use no organization invitation URL by default") {
                    expect(newWebAuth().invitationURL).to(beNil())
                }

                it("should use an organization invitation URL") {
                    let invitationUrl = URL(string: "https://example.com/")!
                    expect(newWebAuth().invitationURL(invitationUrl).invitationURL?.absoluteString).to(equal("https://example.com/"))
                }

            }

        }

        #if os(iOS)
        describe("session") {
            
            context("before start") {
                
                it("should not use ephemeral session by default") {
                    expect(newWebAuth().ephemeralSession).to(beFalse())
                }

                it("should use ephemeral session") {
                    expect(newWebAuth().useEphemeralSession().ephemeralSession).to(beTrue())
                }

            }

            context("after start") {

                let storage = TransactionStore.shared

                beforeEach {
                    if let current = storage.current {
                        storage.cancel(current)
                    }
                }

                it("should save started session") {
                    newWebAuth().start({ _ in})
                    expect(storage.current).toNot(beNil())
                }

                it("should hava a generated state") {
                    let auth = newWebAuth()
                    auth.start({ _ in})
                    expect(storage.current?.state).toNot(beNil())
                }

                it("should honor supplied state") {
                    let state = UUID().uuidString
                    newWebAuth().state(state).start({ _ in})
                    expect(storage.current?.state) == state
                }

                it("should honor supplied state via parameters") {
                    let state = UUID().uuidString
                    newWebAuth().parameters(["state": state]).start({ _ in})
                    expect(storage.current?.state) == state
                }

                it("should generate different state on every start") {
                    let auth = newWebAuth()
                    auth.start({ _ in})
                    let state = storage.current?.state
                    auth.start({ _ in})
                    expect(storage.current?.state) != state
                }

            }

        }

        describe("logout") {

            context("ASWebAuthenticationSession") {

                var outcome: Bool?

                beforeEach {
                    outcome = nil
                    TransactionStore.shared.clear()
                }

                it("should launch AuthenticationServicesSessionCallback") {
                    let auth = newWebAuth()
                    auth.clearSession(federated: false) { _ in }
                    expect(TransactionStore.shared.current).toNot(beNil())
                }

                it("should cancel AuthenticationServicesSessionCallback") {
                    let auth = newWebAuth()
                    auth.clearSession(federated: false) { outcome = $0 }
                    TransactionStore.shared.cancel(TransactionStore.shared.current!)
                    expect(outcome).to(beFalse())
                    expect(TransactionStore.shared.current).to(beNil())
                }

                it("should resume AuthenticationServicesSessionCallback") {
                    let auth = newWebAuth()
                    auth.clearSession(federated: false) { outcome = $0 }
                    _ = TransactionStore.shared.resume(URL(string: "http://fake.com")!)
                    expect(outcome).to(beTrue())
                    expect(TransactionStore.shared.current).to(beNil())
                }

            }

        }
        #endif

    }

}
