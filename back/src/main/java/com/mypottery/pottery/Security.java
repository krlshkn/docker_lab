//package com.mypottery.pottery;
//
//import org.springframework.context.annotation.Bean;
//import org.springframework.context.annotation.Configuration;
//import org.springframework.security.config.annotation.web.builders.HttpSecurity;
//import org.springframework.security.config.annotation.web.builders.WebSecurity;
//import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
//import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
//import org.springframework.security.crypto.password.PasswordEncoder;
//import org.springframework.security.web.SecurityFilterChain;
//
//public class Security {
//
//@Configuration
//@EnableWebSecurity
//public class SecurityConfiguration {
//
//    @Bean
//    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
//        http.csrf().disable()
//                .authorizeRequests()
//                .antMatchers("/admin", "/recordadmin", "/productadmin").hasAuthority("ADMIN")
//                .antMatchers("/account").hasAuthority("USER")
//                .antMatchers("/login", "/reg", "/info", "/programs", "/products").permitAll()
//                .antMatchers("/resources/**", "/static/**", "/js/**").permitAll()
//                .anyRequest().authenticated()
//                .and()
//                .formLogin()
//                .usernameParameter("login")
//                .passwordParameter("password")
//                .loginPage("/login")
//                .defaultSuccessUrl("/info", true)
//                .failureUrl("/login?error=true")
//                .and()
//                .logout().permitAll()
//                .logoutSuccessUrl("/").and()
//                .exceptionHandling().accessDeniedPage("/accessDenied");
//        return http.build();
//    }
//    @Bean
//    public static PasswordEncoder passwordEncoder() {
//        return new BCryptPasswordEncoder();
//    }
//}