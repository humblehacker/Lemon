package com.humblehacker.lemon

import android.content.Intent
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.view.View
import com.humblehacker.lemonlib.LemonActivity

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
    }

    fun showMeALemon(view: View) {
        val intent = Intent(this, LemonActivity::class.java)
        startActivity(intent)
    }
}
