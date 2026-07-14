package middleware

import (
	"context"
	"log"
	"net/http"
	"os"
	"strings"

	"github.com/MicahParks/keyfunc/v3"
	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
)

// RequireAuth valida o access token emitido pelo Supabase Auth (ES256,
// chaves assimétricas publicadas em /auth/v1/.well-known/jwks.json) e
// injeta "userID"/"userEmail" no contexto do Gin a partir das claims
// "sub"/"email". O login/signup em si é feito pelo cliente (iOS)
// diretamente contra o Supabase Auth; este backend só confia no token
// resultante.
func RequireAuth() gin.HandlerFunc {
	jwksURL := os.Getenv("SUPABASE_URL") + "/auth/v1/.well-known/jwks.json"

	k, err := keyfunc.NewDefaultCtx(context.Background(), []string{jwksURL})
	if err != nil {
		log.Fatal("❌ Falha ao carregar o JWKS do Supabase Auth:", err)
	}

	return func(c *gin.Context) {
		header := c.GetHeader("Authorization")
		tokenString, ok := strings.CutPrefix(header, "Bearer ")
		if !ok || tokenString == "" {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "token de autenticação ausente"})
			return
		}

		claims := jwt.MapClaims{}
		token, err := jwt.ParseWithClaims(tokenString, claims, k.Keyfunc)
		if err != nil || !token.Valid {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "token inválido ou expirado"})
			return
		}

		sub, _ := claims["sub"].(string)
		if sub == "" {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "token sem identificador de usuário"})
			return
		}
		email, _ := claims["email"].(string)

		c.Set("userID", sub)
		c.Set("userEmail", email)
		c.Next()
	}
}
