# Tailscale Derper 客户端验证

施工中

<https://github.com/fredliang44/derper-docker/blob/main/Dockerfile>

--verify-clients=$DERP_VERIFY_CLIENTS

verifyClients   = flag.Bool("verify-clients", false, "verify clients to this DERP server through a local tailscaled instance.")

// SetVerifyClients sets whether this DERP server verifies clients through tailscaled.
//
// It must be called before serving begins.
func (s *Server) SetVerifyClient(v bool) {
	s.verifyClientsLocalTailscaled = v
}


verifyClientsURL

verifyClientURL = flag.String("verify-client-url", "", "if non-empty, an admission controller URL for permitting client connections; see tailcfg.DERPAdmitClientRequest")

		jreq, err := json.Marshal(&tailcfg.DERPAdmitClientRequest{
			NodePublic: clientKey,
			Source:     clientIP,
		})
		if err != nil {
			return err
		}
		req, err := http.NewRequestWithContext(ctx, "POST", s.verifyClientsURL, bytes.NewReader(jreq))
		if err != nil {
			return err
		}
		res, err := http.DefaultClient.Do(req)
		if err != nil {
			if s.verifyClientsURLFailOpen {
				s.logf("admission controller unreachable; allowing client %v", clientKey)
				return nil
			}
			return err
		}